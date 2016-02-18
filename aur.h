#ifndef AUR_H
#define AUR_H

#include <curl/curl.h>

typedef enum {
  RPC_SEARCH = 0,
  RPC_SEARCH_BY_MAINTAINER,
  RPC_INFO,
} rpc_type;

struct aur_t {
  char *urlprefix;

  int rpc_version;
};
typedef struct aur_t aur_t;

int aur_new(const char *proto, const char *domain, aur_t **aur);
void aur_free(aur_t *aur);

char *aur_build_rpc_url(aur_t *aur, rpc_type type, const char *arg);
char *aur_build_url(aur_t *aur, const char *urlpath);

#endif  /* AUR_H */
