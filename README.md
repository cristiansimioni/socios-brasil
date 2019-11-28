# socios-brasil :brazil:

Esse projeto tem como objetivo automatizar o processo de baixar os dados do [dataset de cnpj](http://receita.economia.gov.br/orientacao/tributaria/cadastros/cadastro-nacional-de-pessoas-juridicas-cnpj/dados-publicos-cnpj) conhecido como socios-brasil, [converter para CSV](https://github.com/fabioserpa/CNPJ-full) e realizar o upload no Amazon Bucket S3.

O script bash realiza o dowload somente se os arquivos ainda não foram baixados ou se timestamp dos arquivos já baixados forem diferentes dos arquivos disponíveis no website (nova versão da base).

Nesse projeto foi utilizado um [mirror](https://data.brasil.io/mirror/socios-brasil/_meta/list.html) que fornece o mesmo dataset, pois o download via site do governo brasileiro é extremamente lento.

## Dependências

- Docker
- AWS CLI

## Como usar?

1) Clone o código do repositório:

`git clone https://github.com/cristiansimioni/socios-brasil.git`

2) Construa o docker no pasta do repositório:

`cd socios-brasil`

`sudo docker build -t cnpj .`

3) Se você quiser realizar o upload dos arquivos convertidos, será necessário configurar o aws cli. Forneça as keys solicitadas  corretamente:

`aws configure`

4) Execute o comando para realizar todo o processo. Você irá precisa fornecer o nome do Amazon Bucket S3 onde será feito o upload dos arquivos convertidos:

`./socios-brasil.sh -d -c -u -b <bucket name>`

## Como executar os passos separadamente?

- Realizar somente o download dos arquivos zip:

`./socios-brasil.sh -d`

- Converter os arquivos zip em CSV:

`./socios-brasil.sh -c`

- Realizar o upload dos arquivos convertidos no Amazon Bucket S3:

`./socios-brasil.sh -u -b <bucket name>`           
