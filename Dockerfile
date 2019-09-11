ENV SHELL=/bin/bash
RUN apk add --update --no-cache ${BUILD_DEPS} ${PACKAGES} && pip install ${PIP_INSTALL_ARGS} "molecule[${MOLECULE_EXTRAS}]" && gem install ${GEM_PACKAGES} && apk del --no-cache ${BUILD_DEPS} && rm -rf /root/.cache
COPY dir:9f4975397fa3c26f770283b9010eef8354bf7182026824dcb2c8ce007c2734d5 in /usr/src/molecule/dist
ENV MOLECULE_EXTRAS=azure,docker,docs,ec2,gce,hetznercloud,linode,lxc,openstack,vagrant,windows
ENV GEM_PACKAGES=rubocop json etc
ENV PIP_INSTALL_ARGS=--only-binary :all: --no-index -f /usr/src/molecule/dist
ENV BUILD_DEPS=gcc libc-dev make ruby-dev ruby-rdoc
ENV PACKAGES=docker git openssh-client ruby
LABEL maintainer=Ansible <info@ansible.com>
CMD ["python3"]
RUN set -ex; wget -O get-pip.py "$PYTHON_GET_PIP_URL"; echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum -c -; python get-pip.py --disable-pip-version-check --no-cache-dir "pip==$PYTHON_PIP_VERSION" ; pip --version; find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' +; rm -f get-pip.py
ENV PYTHON_GET_PIP_SHA256=201edc6df416da971e64cc94992d2dd24bc328bada7444f0c4f2031ae31e8dad
ENV PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/0c72a3b4ece313faccb446a96c84770ccedc5ec5/get-pip.py
ENV PYTHON_PIP_VERSION=19.2.2
RUN cd /usr/local/bin && ln -s idle3 idle && ln -s pydoc3 pydoc && ln -s python3 python && ln -s python3-config python-config
RUN set -ex && apk add --no-cache --virtual .fetch-deps gnupg tar xz && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" && export GNUPGHOME="$(mktemp -d)" && gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" && gpg --batch --verify python.tar.xz.asc python.tar.xz && { command -v gpgconf > /dev/null && gpgconf --kill all || :; } && rm -rf "$GNUPGHOME" python.tar.xz.asc && mkdir -p /usr/src/python && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz && rm python.tar.xz && apk add --no-cache --virtual .build-deps bzip2-dev coreutils dpkg-dev dpkg expat-dev findutils gcc gdbm-dev libc-dev libffi-dev libnsl-dev libtirpc-dev linux-headers make ncurses-dev openssl-dev pax-utils readline-dev sqlite-dev tcl-dev tk tk-dev util-linux-dev xz-dev zlib-dev && apk del .fetch-deps && cd /usr/src/python && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && ./configure --build="$gnuArch" --enable-loadable-sqlite-extensions --enable-optimizations --enable-shared --with-system-expat --with-system-ffi --without-ensurepip && make -j "$(nproc)" EXTRA_CFLAGS="-DTHREAD_STACK_SIZE=0x100000" PROFILE_TASK='-m test.regrtest --pgo test_array test_base64 test_binascii test_binhex test_binop test_bytes test_c_locale_coercion test_class test_cmath test_codecs test_compile test_complex test_csv test_decimal test_dict test_float test_fstring test_hashlib test_io test_iter test_json test_long test_math test_memoryview test_pickle test_re test_set test_slice test_struct test_threading test_time test_traceback test_unicode ' && make install && find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec scanelf --needed --nobanner --format '%n#p' '{}' ';' | tr ',' '\n' | sort -u | awk 'system("[ -e /usr/local/lib/" $1 " ]") == 0 { next } { print "so:" $1 }' | xargs -rt apk add --no-cache --virtual .python-rundeps && apk del .build-deps && find /usr/local -depth \( \( -type d -a \( -name test -o -name tests \) \) -o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \) -exec rm -rf '{}' + && rm -rf /usr/src/python && python3 --version
ENV PYTHON_VERSION=3.7.4
ENV GPG_KEY=0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
RUN apk add --no-cache ca-certificates
ENV LANG=C.UTF-8
ENV PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
CMD ["/bin/sh"]
ADD file:0eb5ea35741d23fe39cbac245b3a5d84856ed6384f4ff07d496369ee6d960bad in /
