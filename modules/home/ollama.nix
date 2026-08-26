{ pkgs, ... }:

{
  home.packages = [ pkgs.ollama ];

  # The GPU can wire down ~21.8GB of the 32GB, and that has to hold the weights
  # plus the KV cache. 16k leaves room for an 18-19GB model; the quantized KV
  # cache (which needs flash attention) buys back roughly another 0.7GB.
  home.sessionVariables = {
    OLLAMA_HOST = "127.0.0.1:11434";
    OLLAMA_CONTEXT_LENGTH = "16384";
    OLLAMA_FLASH_ATTENTION = "1";
    OLLAMA_KV_CACHE_TYPE = "q8_0";
    OLLAMA_MAX_LOADED_MODELS = "1";
  };
}
