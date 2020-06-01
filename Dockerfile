FROM node:10.16.0-alpine

RUN mkdir -p /var/app
WORKDIR /var/app
COPY docker-entrypoint.sh /docker-entrypoint.sh

COPY ./ /var/app

EXPOSE 8080

ENV GOOGLE_CLIENT_ID=666902240845-nt8eikqldonf8m7pqj5j8s0h4locvc6m.apps.googleusercontent.com
ENV GOOGLE_SECRET=Ei-OlGn8AEWXOehNrmSfS4ow
ENV GOOGLE_CALLBACK_URL=https://escritorio.infoprice.co/auth/google/callback
ENV COOKIE_SESSION_SECRET=matrix-session
ENV COOKIE_SESSION_MAX_AGE=2592000000
ENV ENFORCE_SSL=false
ENV WHITELIST_DOMAINS=["@infoprice.co"]
ENV ROOMS_SOURCE=ENVIRONMENT
ENV ROOMS_DATA='[{"id":"1","name":"Descompressão","disableMeeting":true},{"id":"2","name":"Reunião externa","disableMeeting":true},{"id":"3","name":"Almoço","disableMeeting":true},{"id":"4","name":"Produto e Tecnologia","externalMeetUrl":"https://meet.google.com/urh-xzjn-gcy"},{"id":"5","name":"Dados","externalMeetUrl":"https://meet.google.com/vsc-kwwp-kxm"},{"id":"6","name":"OPS - Data Factory","externalMeetUrl":"https://meet.google.com/hca-ejht-ibk"},{"id":"7","name":"OPS - Atendimento","externalMeetUrl":"https://meet.google.com/nwr-dpxm-wdx"},{"id":"8","name":"Gente e Gestão","externalMeetUrl":"https://meet.google.com/sfw-knzz-mig"},{"id":"9","name":"Comercial","externalMeetUrl":"https://meet.google.com/son-jrmz-orf"},{"id":"10","name":"Financeiro","externalMeetUrl":"https://meet.google.com/gad-dqym-tsx"},{"id":"11","name":"BuscoPreço","externalMeetUrl":"https://meet.google.com/uez-przm-xzw"},{"id":"12","name":"NovoLux","externalMeetUrl":"https://meet.google.com/pvn-qepa-dan"},{"id":"13","name":"BudPricer","externalMeetUrl":"https://meet.google.com/pha-baxf-whq"},{"id":"14","name":"Somos","externalMeetUrl":"https://meet.google.com/gjr-tzwd-uuf"},{"id":"15","name":"Pricell","externalMeetUrl":"https://meet.google.com/exq-njnj-joa"},{"id":"16","name":"SuperBrother","externalMeetUrl":"https://zoom.us/j/2877025860"},{"id":"17","name":"ConheciMentos","externalMeetUrl":"https://meet.google.com/hor-whfv-qxe"},{"id":"18","name":"InfoFlash","externalMeetUrl":"https://meet.google.com/omo-pmdk-wne"},{"id":"19","name":"InfoGram","externalMeetUrl":"https://meet.google.com/wyd-zugu-hio"},{"id":"20","name":"OnBoarding","externalMeetUrl":"https://meet.google.com/nqk-zcsu-vqr"}]'

RUN npm install --ignore-scripts
RUN npm run bootstrap
RUN npm run build-backend
RUN npm run build-frontend

ENTRYPOINT ["sh","/docker-entrypoint.sh"]
CMD ["npm" ,  "--prefix", "backend/", "run", "start-backend"]

