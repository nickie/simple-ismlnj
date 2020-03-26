FROM python:latest

ENV HOME /root
WORKDIR $HOME

RUN pip install ipython jupyter

ENV SMLROOT /usr/local/sml
WORKDIR $SMLROOT

# SML/NJ

## Install `multilib` for 32-bit support that SML/NJ requires.
RUN apt-get update && apt-get install -y gcc-multilib g++-multilib

RUN wget -O - http://smlnj.cs.uchicago.edu/dist/working/110.96/config.tgz | tar zxvf -
RUN config/install.sh

ENV PATH $SMLROOT/bin:$PATH

## Add Kernel

COPY . $HOME/sml
WORKDIR $HOME/sml

RUN jupyter kernelspec install kernels/smlnj

# Add Tini. Tini operates as a process subreaper for jupyter. This prevents kernel crashes.
ENV TINI_VERSION v0.18.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini /usr/bin/tini
RUN chmod +x /usr/bin/tini
ENTRYPOINT ["/usr/bin/tini", "--"]

WORKDIR $HOME/notebook
CMD ["jupyter", "notebook", "--port=8888", "--no-browser", "--allow-root", "--ip=0.0.0.0"]
