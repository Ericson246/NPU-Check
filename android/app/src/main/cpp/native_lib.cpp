#include <jni.h>
#include <android/log.h>
#include <string>
#include <vector>
#include <memory>
#include <cstdlib>
#include <cstring>
#include <chrono>

// llama.cpp includes
#include "llama.h"

#define LOG_TAG "NeuralGauge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Global state
static llama_model* g_model = nullptr;
static llama_context* g_ctx = nullptr;
static bool g_is_loaded = false;
static std::string g_generated_text; // Store generated text

// Token callback function pointer (set from Dart)
typedef void (*TokenCallback)(const char* token, int64_t time_ms);
static TokenCallback g_token_callback = nullptr;

extern "C" {

/**
 * Load a GGUF model from the given file path
 * Returns: 0 on success, -1 on failure
 */
JNIEXPORT jint JNICALL
Java_com_neuralgauge_neural_1gauge_NativeLib_loadModel(
    JNIEnv* env,
    jobject /* this */,
    jstring model_path
) {
    const char* path = env->GetStringUTFChars(model_path, nullptr);
    LOGI("Loading model from: %s", path);

    // Clean up previous model if exists
    if (g_is_loaded) {
        if (g_ctx) llama_free(g_ctx);
        if (g_model) llama_model_free(g_model);
        g_is_loaded = false;
    }

    // Initialize llama backend
    llama_backend_init();

    // Model parameters
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU only for now

    // Load model
    g_model = llama_model_load_from_file(path, model_params);
    env->ReleaseStringUTFChars(model_path, path);

    if (!g_model) {
        LOGE("Failed to load model");
        return -1;
    }

    // Context parameters
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;  // Context size, reasonable default
    // ctx_params.n_batch = 512; // default is 2048 in new API usually, let's leave default or set explicit
    ctx_params.n_threads = 4; // Adjust based on device

    // Create context
    g_ctx = llama_init_from_model(g_model, ctx_params);
    if (!g_ctx) {
        LOGE("Failed to create context");
        llama_model_free(g_model);
        g_model = nullptr;
        return -1;
    }

    g_is_loaded = true;
    LOGI("Model loaded successfully");
    return 0;
}

/**
 * Set the token callback function
 */
JNIEXPORT void JNICALL
Java_com_neuralgauge_neural_1gauge_NativeLib_setTokenCallback(
    JNIEnv* env,
    jobject /* this */,
    jlong callback_ptr
) {
    g_token_callback = reinterpret_cast<TokenCallback>(callback_ptr);
}

/**
 * Run inference with the loaded model
 * Returns: number of tokens generated, or -1 on error
 */
JNIEXPORT jint JNICALL
Java_com_neuralgauge_neural_1gauge_NativeLib_runInference(
    JNIEnv* env,
    jobject /* this */,
    jstring prompt_str,
    jint max_tokens
) {
    if (!g_is_loaded || !g_ctx) {
        LOGE("Model not loaded");
        return -1;
    }

    const char* prompt = env->GetStringUTFChars(prompt_str, nullptr);
    LOGI("Running inference with prompt: %s", prompt);

    const llama_vocab* vocab = llama_model_get_vocab(g_model);

    // Tokenize prompt
    std::vector<llama_token> tokens;
    // Resize to max context to be safe for tokenization result
    int n_ctx = llama_n_ctx(g_ctx);
    tokens.resize(n_ctx);
    
    int n_tokens = llama_tokenize(
        vocab,
        prompt,
        strlen(prompt),
        tokens.data(),
        tokens.size(),
        true,  // add_special
        false  // parse_special
    );

    if (n_tokens < 0) {
        LOGE("Failed to tokenize prompt");
        env->ReleaseStringUTFChars(prompt_str, prompt);
        return -1;
    }

    tokens.resize(n_tokens);
    env->ReleaseStringUTFChars(prompt_str, prompt);

    // Init sampler
    auto sparams = llama_sampler_chain_default_params();
    struct llama_sampler * smpl = llama_sampler_chain_init(sparams);
    llama_sampler_chain_add(smpl, llama_sampler_init_greedy());

    // Evaluate prompt
    // llama_batch_get_one ( tokens, n_tokens ) -> helper
    // It sets pos to 0, 1, 2... automatically for this batch
    if (llama_decode(g_ctx, llama_batch_get_one(tokens.data(), n_tokens))) {
        LOGE("Failed to evaluate prompt");
        llama_sampler_free(smpl);
        return -1;
    }

    // Generate tokens
    int n_generated = 0;
    for (int i = 0; i < max_tokens; i++) {
        auto start_time = std::chrono::high_resolution_clock::now();

        // Sample next token
        // idx -1 means sample from the last token in the context
        llama_token new_token = llama_sampler_sample(smpl, g_ctx, -1);

        // Check for EOS
        if (llama_vocab_is_eog(vocab, new_token)) {
            break;
        }

        // Get token text
        char token_text[256];
        int len = llama_token_to_piece(vocab, new_token, token_text, sizeof(token_text), 0, false);
        if (len < 0) {
             // If buffer is too small, len is negative (usually -needed_len)
             // For safety just handle as error or ignore printing
             // But usually 256 is enough for a token piece
             // If len is positive, it's bytes written
             len = 0; 
        } else {
             token_text[len] = '\0';
        }

        // Calculate inference time
        auto end_time = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);

        // Send token to Dart via callback
        if (g_token_callback) {
            g_token_callback(token_text, duration.count());
        }

        // Prepare for next iteration
        llama_batch batch = llama_batch_get_one(&new_token, 1);
        // Important: set the correct position for the new token
        // Prompt took 0 to n_tokens-1, so next is n_tokens + i
        // Note: llama_batch_get_one sets pos[0] = 0, so we override it
        // Accessing underlying pos array: batch.pos is a pointer
        batch.pos[0] = n_tokens + i;

        if (llama_decode(g_ctx, batch)) {
            LOGE("Failed to evaluate token");
            break;
        }

        n_generated++;
    }

    llama_sampler_free(smpl);
    LOGI("Generated %d tokens", n_generated);
    return n_generated;
}

/**
 * Get current RAM usage in MB
 */
JNIEXPORT jdouble JNICALL
Java_com_neuralgauge_neural_1gauge_NativeLib_getRamUsage(
    JNIEnv* env,
    jobject /* this */
) {
    if (!g_is_loaded || !g_ctx) {
        return 0.0;
    }

    // Get model memory usage
    size_t model_size = llama_model_size(g_model);
    size_t ctx_size = llama_state_get_size(g_ctx);
    
    double total_mb = (model_size + ctx_size) / (1024.0 * 1024.0);
    return total_mb;
}

/**
 * Dispose model and free resources
 */
JNIEXPORT void JNICALL
Java_com_neuralgauge_neural_1gauge_NativeLib_disposeModel(
    JNIEnv* env,
    jobject /* this */
) {
    LOGI("Disposing model");
    
    if (g_ctx) {
        llama_free(g_ctx);
        g_ctx = nullptr;
    }
    
    if (g_model) {
        llama_model_free(g_model);
        g_model = nullptr;
    }
    
    llama_backend_free();
    g_is_loaded = false;
    g_token_callback = nullptr;
}

// ============================================================================
// FFI Functions for Dart (non-JNI)
// ============================================================================

/**
 * Load model - FFI version for Dart
 * Returns: 0 on success, -1 on failure
 */
int32_t load_model(const char* model_path) {
    LOGI("FFI: Loading model from: %s", model_path);
    
    // Clean up previous model if exists
    if (g_is_loaded) {
        if (g_ctx) llama_free(g_ctx);
        if (g_model) llama_model_free(g_model);
        g_is_loaded = false;
    }
    
    // Initialize llama backend
    llama_backend_init();
    
    // Model parameters
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU only for now
    
    // Load model
    g_model = llama_model_load_from_file(model_path, model_params);
    if (!g_model) {
        LOGE("FFI: Failed to load model");
        return -1;
    }
    
    // Context parameters
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 512;  // Smaller context for mobile
    ctx_params.n_batch = 128;
    ctx_params.n_threads = 4;
    
    // Create context
    g_ctx = llama_init_from_model(g_model, ctx_params);
    if (!g_ctx) {
        LOGE("FFI: Failed to create context");
        llama_model_free(g_model);
        g_model = nullptr;
        return -1;
    }
    
    g_is_loaded = true;
    LOGI("FFI: Model loaded successfully");
    return 0;
}

/**
 * Run inference - FFI version for Dart
 * Returns: number of tokens generated, or -1 on error
 */
int32_t run_inference(const char* prompt, int32_t max_tokens) {
    if (!g_is_loaded || !g_model || !g_ctx) {
        LOGE("FFI: Model not loaded");
        return -1;
    }
    
    LOGI("FFI: Running inference with prompt: %s", prompt);
    
    // Clear previous generated text
    g_generated_text.clear();
    
    // Get model vocabulary
    const auto* vocab = llama_model_get_vocab(g_model);
    
    // Tokenize prompt
    std::vector<llama_token> tokens;
    const int n_prompt_tokens = -llama_tokenize(vocab, prompt, strlen(prompt), nullptr, 0, true, true);
    tokens.resize(n_prompt_tokens);
    llama_tokenize(vocab, prompt, strlen(prompt), tokens.data(), tokens.size(), true, true);
    
    LOGI("FFI: Prompt tokenized to %zu tokens", tokens.size());
    
    // Process prompt
    llama_batch batch = llama_batch_get_one(tokens.data(), tokens.size());
    if (llama_decode(g_ctx, batch) != 0) {
        LOGE("FFI: Failed to decode prompt");
        return -1;
    }
    
    // Generate tokens
    int n_generated = 0;
    std::string generated_text;
    
    for (int i = 0; i < max_tokens; i++) {
        // Sample next token
        auto* logits = llama_get_logits_ith(g_ctx, -1);
        auto n_vocab = llama_n_vocab(vocab);
        
        // Simple greedy sampling
        llama_token new_token = 0;
        float max_logit = logits[0];
        for (int j = 1; j < n_vocab; j++) {
            if (logits[j] > max_logit) {
                max_logit = logits[j];
                new_token = j;
            }
        }
        
        // Check for end of generation
        if (llama_vocab_is_eog(vocab, new_token)) {
            LOGI("FFI: End of generation");
            break;
        }
        
        // Convert token to text
        const char* token_str = llama_vocab_get_text(vocab, new_token);
        if (token_str && strlen(token_str) > 0) {
            generated_text += token_str;
            
            // Call callback if set
            if (g_token_callback) {
                auto now = std::chrono::system_clock::now();
                auto ms = std::chrono::duration_cast<std::chrono::milliseconds>(
                    now.time_since_epoch()
                ).count();
                g_token_callback(token_str, ms);
            }
        }
        
        // Prepare next batch
        batch = llama_batch_get_one(&new_token, 1);
        if (llama_decode(g_ctx, batch) != 0) {
            LOGE("FFI: Failed to decode token");
            break;
        }
        
        n_generated++;
    }
    
    // Store generated text in global variable
    g_generated_text = generated_text;
    
    LOGI("FFI: Generated %d tokens: %s", n_generated, generated_text.c_str());
    return n_generated;
}

/**
 * Dispose model - FFI version for Dart
 */
void dispose_model() {
    LOGI("FFI: Disposing model");
    
    if (g_ctx) {
        llama_free(g_ctx);
        g_ctx = nullptr;
    }
    
    if (g_model) {
        llama_model_free(g_model);
        g_model = nullptr;
    }
    
    llama_backend_free();
    g_is_loaded = false;
    g_token_callback = nullptr;
}

/**
 * Set token callback - FFI version for Dart
 */
void set_token_callback(TokenCallback callback) {
    LOGI("FFI: Setting token callback");
    g_token_callback = callback;
}

/**
 * Get generated text - FFI version for Dart
 * Returns: pointer to generated text string
 */
const char* get_generated_text() {
    return g_generated_text.c_str();
}

} // extern "C"
