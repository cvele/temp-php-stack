ARG TZ=Europe/Belgrade
FROM ejabberd/ecs:21.12
ENV TZ=${TZ}

RUN nohup /home/ejabberd/bin/ejabberdctl foreground & > /dev/null && \
     sleep 5 && \
     /home/ejabberd/bin/ejabberdctl modules_update_specs && \
     /home/ejabberd/bin/ejabberdctl module_install ejabberd_auth_http

RUN sed -i 's/## mod_mam:/mod_mam: {}/g' /home/ejabberd/conf/ejabberd.yml

RUN mkdir -p /home/ejabberd/.ejabberd-modules/sources/mod_offline_http_post_notify/src \
     && touch /home/ejabberd/.ejabberd-modules/sources/mod_offline_http_post_notify/mod_offline_http_post_notify.spec \
     && echo "summary: \"mod_offline_http_post_notify\"" > /home/ejabberd/.ejabberd-modules/sources/mod_offline_http_post_notify/mod_offline_http_post_notify.spec
ADD .docker/ejabberd/mod_offline_http_post_notify.erl /home/ejabberd/.ejabberd-modules/sources/mod_offline_http_post_notify/src

RUN nohup /home/ejabberd/bin/ejabberdctl foreground & > /dev/null && \
     sleep 5 && \
     /home/ejabberd/bin/ejabberdctl module_install mod_offline_http_post_notify 

RUN mkdir -p /home/ejabberd/.ejabberd-modules/sources/mod_user_status/src \
     && touch /home/ejabberd/.ejabberd-modules/sources/mod_user_status/mod_user_status.spec \
     && echo "summary: \"mod_user_status\"" > /home/ejabberd/.ejabberd-modules/sources/mod_user_status/mod_user_status.spec
ADD .docker/ejabberd/mod_user_status.erl /home/ejabberd/.ejabberd-modules/sources/mod_user_status/src

RUN nohup /home/ejabberd/bin/ejabberdctl foreground & > /dev/null && \
     sleep 5 && \
     /home/ejabberd/bin/ejabberdctl module_install mod_user_status 

RUN mkdir /home/ejabberd/.ejabberd-modules/sources/mod_unread && \ 
     cd /home/ejabberd/.ejabberd-modules/sources/mod_unread && \
     wget https://github.com/cvele/ejabberd-unread/archive/refs/heads/21.12.zip && \
     unzip 21.12.zip && \
     mv ejabberd-unread-21.12/* . && \
     rm -rf 21.12.zip && \
     nohup /home/ejabberd/bin/ejabberdctl foreground & > /dev/null && \ 
     sleep 10 && /home/ejabberd/bin/ejabberdctl module_install mod_unread 

COPY .docker/ejabberd/ejabberd.yml /home/ejabberd/conf/ejabberd.yml

     



