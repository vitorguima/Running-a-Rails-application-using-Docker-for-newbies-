# deriva imagem do ruby utilizada no esqueleto criado
FROM ruby:3.0.2

# instala o bundler (gerenciador de pacotes)
RUN gem install bundler

# instala o node.js
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - && \
    echo 'deb https://dl.yarnpkg.com/debian/ stable main' > /etc/apt/sources.list.d/yarn.list &&\
    wget -q -O - https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - &&\
    apt-get update -qq && \
    apt-get install -y build-essential nodejs yarn
# o diretório local (criado no passo "criacao do esqueleto da aplicacao, será apontado para esse diretório dentro do container")
WORKDIR /var/app

COPY . .

RUN bundler install

ENTRYPOINT ["./entrypoint.sh"]