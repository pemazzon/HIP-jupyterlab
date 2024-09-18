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

RUN mamba create -y --override-channels --channel=conda-forge --name=PHI_env \
    'numpy' 'pandas' 'scipy' \
    'scikit-learn' 'tensorflow' 'pytorch' \
    'matplotlib' 'seaborn' \
    'nltk' 'spacy' \
    'joblib' 'tqdm' \
    'streamlit' \
    'opencv' 'pillow' \
    'lifelines' 'scikit-survival' \
    'nibabel' 'nilearn' 'dipy' 'pysurfer'

SHELL ["conda", "run", "-n", "PHI_env", "/bin/bash", "-c"]

RUN pip install deepbrain tedana

ENV APP_SPECIAL="jupyterlab-desktop"
ENV APP_CMD=""
ENV PROCESS_NAME=""
ENV APP_DATA_DIR_ARRAY=".jupyter"
ENV DATA_DIR_ARRAY=""

HEALTHCHECK --interval=10s --timeout=10s --retries=5 --start-period=30s \
  CMD sh -c "/apps/${APP_NAME}/scripts/process-healthcheck.sh \
  && /apps/${APP_NAME}/scripts/ls-healthcheck.sh /home/${HIP_USER}/nextcloud/"

COPY ./scripts/ scripts/

ENTRYPOINT ["./scripts/docker-entrypoint.sh"]
