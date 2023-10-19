FROM python:3.10

RUN --mount=type=secret,id=MODULAR_AUTH \
  curl https://get.modular.com | MODULAR_AUTH=$(cat /run/secrets/MODULAR_AUTH) sh -

RUN modular install mojo

ENV MODULAR_HOME=/root/.modular
ENV PATH="/root/.modular/pkg/packages.modular.com_mojo/bin:$PATH"

WORKDIR /app
COPY . .
RUN mojo run_all_tests.mojo
RUN mojo run_all_tests.mojo
