FROM python:3.6.8
RUN git clone https://github.com/fabioserpa/CNPJ-full.git
RUN python3 -m pip install --upgrade pip
RUN pip install -r CNPJ-full/requirements.txt