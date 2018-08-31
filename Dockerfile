FROM alpine: mais recente AS CLONE_CODE
 ARG FORPDI_REPO_URL = https: //github.com/forpdi/forpdi.git
 ARG FORPDI_REPO_BRANCH = master
 RUN apk Adicionar --update-cache --no-cache git
 RUN git clone --depth 1 $ FORPDI_REPO_URL / forpdi -b $ FORPDI_REPO_BRANCH

 FROM nó: 6 -alpine AS BUILD_FRONTEND COPY --from
 = CLONE_CODE / forpdi / forpdi
 WORKDIR / forpdi / backend-java / src / principal / frontend /
 RUN npm -g instalar webpack
 RUN npm instalar
 RUN npm executar build
 
FROM maven: 3-jdk- 8 -alpine AS BUILD_BACKEND COPY --pt
 = de = BUILD_FRONTEND / forpdi / forpdi
 WORKDIR / forpdi / backend-java /
 EXECUTAR cp dev.properties prd.properties
 RUN sed -i 's /.* connection \ .url. * / <! - & -> / ' src / main / resources / hibernate.cfg.xml \ && sed -i ' s /.* connection \ .username. * / <! - & -> / ' src / main / resources / hibernate.cfg.xml \ && sed -i 's /.* connection \ .password. * / <! - & -> /' src / main / resources / hibernate.cfg.xml
 EXECUTAR instalação mvn -P prd -B -q
 COPIAR entrypoint.sh /deploy/entrypoint.sh
 RUNcp /forpdi/backend-java/target/forpdi.war / deploy \ && chmod + x /deploy/entrypoint.sh
 
FROM jboss / wildfly: 9.0 . 2 .Final
 ARG BUILD_DATE
 ARG VCS_REF
 ARG VERSION
 LABEL org.label-schema.build-date = $ BUILD_DATE \ org.label-schema.name = "DockerPDI do ForPDI" \ org.label-schema.description = "Solução Aberta para elaboração e Administração do PDI " \ org.label-schema.url = " http://www.forpdi.org/ " \ org.label-schema.vcs-ref = $ VCS_REF \ org.label-schema.vcs-url = " https://github.com/forpdi/forpdi "\ org.label-schema.vendor = "Evandro Evangelista" \ org.label-schema.version = $ VERSION \ org.label-schema.schema-version = "1.0"
 COPY --from = BUILD_BACKEND / deploy / opt / jboss / wildfly / standalone / deployments /
 ENTRYPOINT [ "/opt/jboss/wildfly/standalone/deployments/entrypoint.sh" ]
 CMD [ "/opt/jboss/wildfly/bin/standalone.sh" , "-b" , "0.0 .0.0 " , " -P " , " forpdi.properties " ]
