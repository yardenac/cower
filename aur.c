#include "aur.h"

#include <errno.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <stdio.h>

static char *aur_vurlf(struct aur_t *aur, const char *urlpath_format, va_list ap) {
	int len;
	va_list aq;
	char *out, *p;

	va_copy(aq, ap);
	len = strlen(aur->urlprefix) + strlen("/") +
			vsnprintf(NULL, 0, urlpath_format, aq) + 1;
	va_end(aq);

	out = malloc(len);
	if(out == NULL) {
		return NULL;
	}

	p = stpcpy(out, aur->urlprefix);
	*p++ = '/';
	p += vsprintf(p, urlpath_format, ap);
	*p = '\0';

	return out;
}

static char *aur_urlf(struct aur_t *aur, const char *urlpath_format, ...) {
	va_list ap;
	char *out;

	va_start(ap, urlpath_format);
	out = aur_vurlf(aur, urlpath_format, ap);
	va_end(ap);

	return out;
}

char *aur_build_rpc_url(struct aur_t *aur, const char *method, const char *escaped_arg) {
	return aur_urlf(aur, "/rpc.php?v=%d&type=%s&arg=%s", aur->rpc_version, method, escaped_arg);
}

char *aur_build_url(struct aur_t *aur, const char *urlpath) {
	return aur_urlf(aur, urlpath);
}

int aur_new(const char *proto, const char *domain, struct aur_t **aur) {
	struct aur_t *a;

	if (proto == NULL || domain == NULL) {
		return -EINVAL;
	}

	a = calloc(1, sizeof(*a));
	if (a == NULL) {
		return -ENOMEM;
	}

	if (asprintf(&a->urlprefix, "%s://%s", proto, domain) < 0) {
		free(a);
		return -ENOMEM;
	}

	a->rpc_version = 4;

	*aur = a;
	return 0;
}

