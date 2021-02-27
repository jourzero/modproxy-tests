FROM httpd:latest
RUN apt-get -yqq update && apt-get -yqq dist-upgrade 
RUN apt-get -y install lsof procps vim net-tools ca-certificates 

ENV ACCESSLOG=/var/log/apache2/access.log \
    BACKEND=http://localhost:80 \
    BACKEND_WS=ws://localhost:8080 \
    ERRORLOG=/var/log/apache2/error.log \
    H2_PROTOCOLS='h2 http/1.1' \
    LOGLEVEL=warn \
    METRICS_ALLOW_FROM='127.0.0.0/255.0.0.0 ::1/128' \
    METRICS_DENY_FROM='All' \
    METRICSLOG='/dev/null combined' \
    MODSEC_AUDIT_LOG_FORMAT=JSON \
    MODSEC_AUDIT_LOG_TYPE=Serial \
    MODSEC_AUDIT_LOG=/dev/stdout \
    MODSEC_AUDIT_STORAGE=/var/log/modsecurity/audit/ \
    MODSEC_DATA_DIR=/tmp/modsecurity/data \
    MODSEC_DEBUG_LOG=/dev/null \
    MODSEC_DEBUG_LOGLEVEL=0 \
    MODSEC_PCRE_MATCH_LIMIT_RECURSION=500000 \
    MODSEC_PCRE_MATCH_LIMIT=500000 \
    MODSEC_REQ_BODY_ACCESS=on \
    MODSEC_REQ_BODY_LIMIT=13107200 \
    MODSEC_REQ_BODY_NOFILES_LIMIT=131072 \
    MODSEC_RESP_BODY_ACCESS=on \
    MODSEC_RESP_BODY_LIMIT=1048576 \
    MODSEC_RULE_ENGINE=on \
    MODSEC_TAG=modsecurity \
    MODSEC_TMP_DIR=/tmp/modsecurity/tmp \
    MODSEC_UPLOAD_DIR=/tmp/modsecurity/upload \
    PERFLOG='/dev/stdout perflogjson env=write_perflog' \
    PORT=80 \
    PROXY_PRESERVE_HOST=on \
    PROXY_SSL_CA_CERT=/etc/ssl/certs/ca-certificates.crt \
    PROXY_SSL_CERT_KEY=/usr/local/apache2/conf/server.key \
    PROXY_SSL_CERT=/usr/local/apache2/conf/server.crt \
    PROXY_SSL_CHECK_PEER_NAME=off \
    PROXY_SSL_VERIFY=none \
    PROXY_SSL=on  \
    PROXY_TIMEOUT=60 \
    REMOTEIP_INT_PROXY='10.1.0.0/16' \
    REQ_HEADER_FORWARDED_PROTO='https' \
    SERVER_ADMIN=root@localhost \
    SERVER_NAME=localhost \
    SSL_ENGINE=on \
    SSL_PORT=443 \
    TIMEOUT=60 \
    WORKER_CONNECTIONS=400

COPY extra/*.conf /usr/local/apache2/conf/extra/

RUN sed -i -E 's|(Listen) [0-9]+|\1 ${PORT}|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|(ServerTokens) Full|\1 Prod|' /usr/local/apache2/conf/extra/httpd-default.conf \
 && sed -i -E 's|#(ServerName) www.example.com:80|\1 ${SERVER_NAME}|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule unique_id_module)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule rewrite_module modules/mod_rewrite.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule proxy_module modules/mod_proxy.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule proxy_http_module modules/mod_proxy_http.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule remoteip_module modules/mod_remoteip.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule socache_shmcb_module modules/mod_socache_shmcb.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule ssl_module modules/mod_ssl.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(LoadModule http2_module modules/mod_http2.so)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(Include conf/extra/httpd-default.conf)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(Include conf/extra/httpd-proxy.conf)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|#(Include conf/extra/httpd-vhosts.conf)|\1|' /usr/local/apache2/conf/httpd.conf \
 && sed -i -E 's|(MaxRequestWorkers[ ]*)[0-9]*|\1${WORKER_CONNECTIONS}|' /usr/local/apache2/conf/extra/httpd-mpm.conf


# Use httpd-foreground from upstream