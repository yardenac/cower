
struct aur_t {
	char *urlprefix;

	int rpc_version;
};

int aur_new(const char *proto, const char *domain, struct aur_t **aur);
char *aur_build_rpc_url(struct aur_t *aur, const char *method, const char *arg);
char *aur_build_url(struct aur_t *aur, const char *urlpath);
