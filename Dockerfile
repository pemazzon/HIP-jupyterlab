ARG CI_REGISTRY_IMAGE
ARG TAG
ARG DOCKERFS_TYPE
ARG DOCKERFS_VERSION
ARG JUPYTERLAB_DESKTOP_VERSION
FROM ${CI_REGISTRY_IMAGE}/jupyterlab-desktop:${JUPYTERLAB_DESKTOP_VERSION}${TAG}
LABEL maintainer="florian.sipp@chuv.ch"

ARG DEBIAN_FRONTEND=noninteractive
ARG CARD
ARG CI_REGISTRY
ARG APP_NAME
ARG APP_VERSION

LABEL app_version=$APP_VERSION
LABEL app_tag=$TAG

WORKDIR /apps/${APP_NAME}

ENV PATH="/apps/jupyterlab-desktop/conda/bin:${PATH}"

RUN mamba create -y --override-channels --channel=conda-forge --name=bioinformatics_env \
    # Core Libraries \
    'numpy>=1.19.2' 'pandas>=1.3.0' 'scipy>=1.7.0' \
    # Machine Learning Libraries : \
    # under conda torch is named pytorch \
    'scikit-learn>=0.24.2' 'tensorflow>=2.5.0' 'pytorch>=1.9.0' \
    # Data Visualization Libraries
    'matplotlib>=3.4.2' 'seaborn>=0.11.1' \
    # Natural Language Processing Libraries
    'nltk>=3.6.2' 'spacy>=3.1.1' \
    # Misc Libraries
    'joblib>=1.0.1' 'tqdm>=4.61.2' \
    # Streamlit for Web Apps
    'streamlit>=0.83.0' \
    # Utilities : \
    # under conda opencv-python is opencv \
    #             Pillow is pillow \
    'opencv>=4.5.3' 'pillow>=8.3.1' \
    # Survival Analysis \
    'lifelines' 'scikit-survival'

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
