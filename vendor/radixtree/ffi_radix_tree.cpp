#include <algorithm>
#include <iostream>
#include <cstring>
#include <string>
#include <vector>

#include "radix_tree.hpp"

#ifdef __cplusplus
#define EXTERN_C       extern "C"
#define EXTERN_C_BEGIN extern "C" {
#define EXTERN_C_END   }
#else
#define EXTERN_C       /* Nothing */
#define EXTERN_C_BEGIN /* Nothing */
#define EXTERN_C_END   /* Nothing */
#endif

EXTERN_C_BEGIN
radix_tree<std::string, std::vector<char>>* create() {
  radix_tree<std::string, std::vector<char>>* map_pointer = new radix_tree<std::string, std::vector<char>>();

  return map_pointer;
}

void erase(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key) {
  map_pointer->erase(std::string(key));
}

bool has_key(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key) {
  return map_pointer->find(std::string(key)) != map_pointer->end();
}

void match_free(const char* match) {
  if (match != NULL) {
    delete[] match;
    match = NULL;
  }
}

const char* longest_prefix(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key) {
  std::string string_key(key);
  auto iter = map_pointer->longest_match(string_key);

  if (iter != map_pointer->end()) {
    char *val  = new char[iter->first.size() + 1]{0};
    val[iter->first.size()] = '\0';
    memcpy(val, iter->first.c_str(), iter->first.size());

    return val;
  }
  
  return NULL;
}

const char* longest_prefix_value(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, int* read_size) {
  std::string string_key(key);
  auto iter = map_pointer->longest_match(string_key);
  long counter = 0;

  if (iter != map_pointer->end()) {
    char *return_val  = new char[iter->second.size()]{0};
    for( auto& val : iter->second ) {
      return_val[counter] = val;
      counter++;
    }

    *read_size = iter->second.size();
    return return_val;
  }
  
  *read_size = 0;
  return NULL;
}

const char* fetch(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, int* read_size) {
  auto iter = map_pointer->find(std::string(key));
  long counter = 0;

  if (iter != map_pointer->end()) {
    char *return_val  = new char[iter->second.size()]{0};
    for( auto& val : iter->second ) {
      return_val[counter] = val;
      counter++;
    }

    *read_size = iter->second.size();
    return return_val;
  }

  *read_size = 0;
  return NULL;
}

void insert(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, char* value, size_t size) {
  map_pointer->insert({std::string(key), std::vector<char>(value, value + size)});
}

void destroy(radix_tree<std::string, std::vector<char>>* map_pointer) {
  delete map_pointer;
  map_pointer = NULL;
}
EXTERN_C_END
