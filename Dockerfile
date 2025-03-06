ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}${TAG}
LABEL maintainer="paoloemilio.mazzon@unipd.it"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

ENV PATH="/apps/jupyterlab-desktop/conda/bin:${PATH}"

# There's a default environment shipped 
# from the base image called jlab_env
# We install everything inside there!
RUN mamba install -y --override-channels --channel=conda-forge \
    'numpy' 'pandas' 'scipy' \
    'scikit-learn' 'tensorflow' 'pytorch' 'pysurfer' \
    'matplotlib' 'seaborn' \
    'nltk' 'spacy' \
    'joblib' 'tqdm' \
    'streamlit' \
    'opencv' 'pillow' \
    'lifelines' 'scikit-survival' \
    'nibabel' 'nilearn' 'dipy'

# For some reason I'm no more able to create a new env and
# get jupyter-lab to digest it. So I'm using the default jlab_env
SHELL ["mamba", "run", "-n", "jlab_env", "/bin/bash", "-c"]

RUN pip install deepbrain

ENV APP_SPECIAL="jupyterlab-desktop"
# guess what: APP_CMD_PREFIX gets overwritten from 
# a-i-b/services/scripts/run-app.sh in case you're
# running jupyterlab-desktop. How about adding a note
# somewhere?
ENV APP_CMD_PREFIX=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=".jupyter"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
