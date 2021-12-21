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
  delete[] match;
}

void match_sizes_free(const int* match_sizes) {
  delete[] match_sizes;
}

void multi_match_free(const char** match, int length) {
  if (match != NULL) {
    for (int i=0; i<length; ++i) {
      delete[] match[i];
    }
    delete[] match;
  }
}

const char* longest_prefix(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key) {
  std::string string_key(key);
  auto iter = map_pointer->longest_match(string_key);

  if (iter != map_pointer->end()) {
    char *val  = new char[iter->first.size() + 1]{0};
    memcpy(val, iter->first.c_str(), iter->first.size());

    return val;
  }
  
  return NULL;
}

const char* longest_prefix_and_value(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, int* read_size, int* prefix_size) {
  std::string string_key(key);
  auto iter = map_pointer->longest_match(string_key);

  if (iter != map_pointer->end()) {
    long counter = 0;
    int size_of_response = iter->second.size() + iter->first.size();
    char *return_val  = new char[size_of_response]{0};

    strncpy(return_val, iter->first.c_str(), iter->first.size());
    counter = iter->first.size();

    for( auto& val3 : iter->second) {
      return_val[counter] = val3;
      counter++;
    }

    *prefix_size = iter->first.size();
    *read_size = size_of_response;
    return return_val;
  }

  *prefix_size = 0;
  *read_size = 0;
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

char* fetch(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, int* read_size) {
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

int greedy_match(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, const char*** matches, int** match_sizes) {
  std::string string_key(key);
  typedef radix_tree<std::string, std::vector<char>>::iterator iterator;
  std::vector<iterator> vec;
  map_pointer->greedy_match(string_key, vec);
  long counter = 0;

  if (vec.size() > 0) {
    *matches = new const char* [vec.size()]{nullptr};
    *match_sizes = new int [vec.size()]{0};
    for (auto& iter : vec) {
      auto ret_str = new char[iter->second.size()];
      long char_index = 0;
      for (auto& val : iter->second) {
        ret_str[char_index] = val;
        ++char_index;
      }
      (*matches)[counter] = ret_str;
      (*match_sizes)[counter] = iter->second.size();
      ++counter;
    }
  }
  return counter;
}

int greedy_substring_match(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, const char*** matches, int** match_sizes) {
  std::string string_key(key);
  typedef radix_tree<std::string, std::vector<char>>::iterator iterator;
  std::vector<iterator> vec;
  map_pointer->greedy_substring_match(string_key, vec);
  long counter = 0;

  if (vec.size() > 0) {
    *matches = new const char* [vec.size()]{nullptr};
    *match_sizes = new int [vec.size()]{0};
    for (auto& iter : vec) {
      auto ret_str = new char[iter->second.size()];
      long char_index = 0;
      for (auto& val : iter->second) {
        ret_str[char_index] = val;
        ++char_index;
      }
      (*matches)[counter] = ret_str;
      (*match_sizes)[counter] = iter->second.size();
      ++counter;
    }
  }
  return counter;
}

void insert(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, char* value, size_t size) {
  map_pointer->insert({std::string(key), std::vector<char>(value, value + size)});
}

bool update(radix_tree<std::string, std::vector<char>>* map_pointer, const char* key, char* value, size_t size) {
  return map_pointer->update({std::string(key), std::vector<char>(value, value + size)});
}

void destroy(radix_tree<std::string, std::vector<char>>* map_pointer) {
  delete map_pointer;
  map_pointer = NULL;
}
EXTERN_C_END
