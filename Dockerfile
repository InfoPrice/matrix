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
ENV ROOMS_DATA='[{"id": "1","name": "Descompressão","disableMeeting": true},{"id": "2","name": "Reunião externa","disableMeeting": true},{"id": "3","name": "Almoço","disableMeeting": true},{"id": "4","name": "Produto e Tecnologia","externalMeetUrl": "https://meet.google.com/pcq-npbs-vzz"},{"id": "5","name": "Dados","externalMeetUrl": "https://meet.google.com/vfx-oaux-ivd"},{"id": "6","name": "OPS - Data Factory","externalMeetUrl": "https://meet.google.com/hca-ejht-ibk"},{"id": "7","name": "OPS - Atendimento","externalMeetUrl": "https://meet.google.com/nwc-puxv-nwu"},{"id": "8","name": "Gente e Gestão","externalMeetUrl": "https://meet.google.com/rro-jwst-gsw"},{"id": "9","name": "Comercial","externalMeetUrl": "https://meet.google.com/ogu-zosr-sdy"},{"id": "10","name": "Financeiro","externalMeetUrl": "https://meet.google.com/zhc-dmxw-hbd"},{"id": "11","name": "BuscoPreço","externalMeetUrl": "https://meet.google.com/ywy-iwxk-nzb"},{"id": "12","name": "NovoLux","externalMeetUrl": "https://meet.google.com/zgb-rihz-ian"},{"id": "13","name": "BudPricer","externalMeetUrl": "https://meet.google.com/uvz-fpss-htb"},{"id": "14","name": "Somos","externalMeetUrl": "https://meet.google.com/fwj-sbxm-hih"},{"id": "15","name": "Pricell","externalMeetUrl": "https://meet.google.com/uts-bwsj-hqq"},{"id": "16","name": "SuperBrother (Zoom)","externalMeetUrl": "https://zoom.us/j/2877025860"},{"id": "17","name": "ConheciMentos","externalMeetUrl": "https://meet.google.com/npt-ybid-zdf"},{"id": "18","name": "InfoFlash","externalMeetUrl": "https://meet.google.com/mhq-xyvi-ysz"},{"id": "19","name": "InfoGram","externalMeetUrl": "https://meet.google.com/ayh-yxnx-efg"},{"id": "20","name": "OnBoarding","externalMeetUrl": "https://meet.google.com/frx-xfkf-afp"}]'

RUN npm install --ignore-scripts
RUN npm run bootstrap
RUN npm run build-backend
RUN npm run build-frontend

ENTRYPOINT ["sh","/docker-entrypoint.sh"]
CMD ["npm" ,  "--prefix", "backend/", "run", "start-backend"]

