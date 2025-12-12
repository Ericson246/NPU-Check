#include <jni.h>
#include <android/log.h>
#include <string>
#include <memory>
#include <cstdlib>
#include <cstring>

// llama.cpp includes
#include "llama.h"
#include "common.h"

#define LOG_TAG "NeuralGauge"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Global state
static llama_model* g_model = nullptr;
static llama_context* g_ctx = nullptr;
static bool g_is_loaded = false;

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
        if (g_model) llama_free_model(g_model);
        g_is_loaded = false;
    }

    // Initialize llama backend
    llama_backend_init();

    // Model parameters
    llama_model_params model_params = llama_model_default_params();
    model_params.n_gpu_layers = 0; // CPU only for now, can enable GPU later

    // Load model
    g_model = llama_load_model_from_file(path, model_params);
    env->ReleaseStringUTFChars(model_path, path);

    if (!g_model) {
        LOGE("Failed to load model");
        return -1;
    }

    // Context parameters
    llama_context_params ctx_params = llama_context_default_params();
    ctx_params.n_ctx = 2048;  // Context size
    ctx_params.n_batch = 512;
    ctx_params.n_threads = 4; // Adjust based on device

    // Create context
    g_ctx = llama_new_context_with_model(g_model, ctx_params);
    if (!g_ctx) {
        LOGE("Failed to create context");
        llama_free_model(g_model);
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

    // Tokenize prompt
    std::vector<llama_token> tokens;
    tokens.resize(llama_n_ctx(g_ctx));
    
    int n_tokens = llama_tokenize(
        g_model,
        prompt,
        strlen(prompt),
        tokens.data(),
        tokens.size(),
        true,  // add_bos
        false  // special
    );

    if (n_tokens < 0) {
        LOGE("Failed to tokenize prompt");
        env->ReleaseStringUTFChars(prompt_str, prompt);
        return -1;
    }

    tokens.resize(n_tokens);
    env->ReleaseStringUTFChars(prompt_str, prompt);

    // Evaluate prompt
    if (llama_decode(g_ctx, llama_batch_get_one(tokens.data(), n_tokens, 0, 0))) {
        LOGE("Failed to evaluate prompt");
        return -1;
    }

    // Generate tokens
    int n_generated = 0;
    for (int i = 0; i < max_tokens; i++) {
        auto start_time = std::chrono::high_resolution_clock::now();

        // Sample next token
        llama_token new_token = llama_sampler_sample(
            llama_sampler_chain_default_params(),
            g_ctx,
            -1
        );

        // Check for EOS
        if (llama_token_is_eog(g_model, new_token)) {
            break;
        }

        // Get token text
        char token_text[256];
        int len = llama_token_to_piece(g_model, new_token, token_text, sizeof(token_text), 0, false);
        if (len < 0) {
            LOGE("Failed to convert token to text");
            break;
        }
        token_text[len] = '\0';

        // Calculate inference time
        auto end_time = std::chrono::high_resolution_clock::now();
        auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_time - start_time);

        // Send token to Dart via callback
        if (g_token_callback) {
            g_token_callback(token_text, duration.count());
        }

        // Prepare for next iteration
        if (llama_decode(g_ctx, llama_batch_get_one(&new_token, 1, n_tokens + i, 0))) {
            LOGE("Failed to evaluate token");
            break;
        }

        n_generated++;
    }

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
    size_t ctx_size = llama_get_state_size(g_ctx);
    
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
        llama_free_model(g_model);
        g_model = nullptr;
    }
    
    llama_backend_free();
    g_is_loaded = false;
    g_token_callback = nullptr;
}

} // extern "C"
