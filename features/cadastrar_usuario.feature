#language: pt

Funcionalidade: Cadastrar usuário
  Como um novo usuário do solar
  Eu quero me cadastrar
  Para acessar os recursos do sistema

Cenário: Acessar página de cadastro de novo usuário
	Dado que eu nao estou cadastrado
		E que estou em "Login"
                E eu clico no link "Cadastrar"
	Então eu deverei ver "Login"
		E eu deverei ver "Senha"
		E eu deverei ver "Confirmação da senha"
		E eu deverei ver "Apelido"
		E eu deverei ver "E-mail"
                E eu deverei ver "Confirmação do e-mail"
		E eu deverei ver "E-mail alternativo"
		E eu deverei ver "Instituição"
                E eu deverei ver "Nome"
		E eu deverei ver "Data de Nascimento"
		E eu deverei ver "Sexo"
		E eu deverei ver "Cpf"
		E eu deverei ver "Endereço"
		E eu deverei ver "Número"
		E eu deverei ver "Complemento"
		E eu deverei ver "Bairro"
		E eu deverei ver "CEP"
		E eu deverei ver "País"
		E eu deverei ver "Estado"
		E eu deverei ver "Cidade"
		E eu deverei ver "Telefone"
		E eu deverei ver "Celular"
		E eu deverei ver "Necessidades especiais"
		E eu deverei ver o botao "Confirmar"

Cenário: Cadastrar novo usuário
    Dado que estou em "Cadastrar usuario"
       E que eu preenchi "username" com "usuario"
       E que eu preenchi "password" com "123456"
       E que eu preenchi "password_confirmation" com "123456"
       E que eu preenchi "nick" com "usuario"
       E que eu preenchi "email" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "email_confirmation" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "institution" com "Inst"
       E que eu preenchi "name" com "Usuário do Solar"
       E que eu selecionei a data "13/12/2001" no campo com id "user_birthdate"
       E que eu selecionei "Sexo" com "M"
       E que eu preenchi "cpf" com "724.164.753-04"
       E que eu preenchi "address" com "Rua Sei Não"
       E que eu preenchi "address_number" com "123"
       E que eu preenchi "address_complement" com "Ap 000"
       E que eu preenchi "address_neighborhood" com "Sei lá qual"
       E que eu preenchi "zipcode" com "60000-000"
       E que eu preenchi "country" com "Brasil"
       E que eu selecionei "Estado" com "CE"
       E que eu preenchi "city" com "Fortaleza"
       E que eu preenchi "telephone" com "(85)3322-2233"
       E que eu preenchi "cell_phone" com "(85)8888-8888"
    Quando eu clicar em "confirm"
    Então eu deverei ver "Sair"
        E eu deverei ver "Home"

Cenário: Cadastrar novo usuário com dados inválidos
    Dado que estou em "Cadastrar usuario"
       E que eu preenchi "username" com ""
       E que eu preenchi "password" com "123456"
       E que eu preenchi "password_confirmation" com "123456"
       E que eu preenchi "nick" com "usuario"
       E que eu preenchi "email" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "email_confirmation" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "institution" com "Inst"
       E que eu preenchi "name" com "Usuário do Solar"
       E que eu selecionei a data "13/12/2001" no campo com id "user_birthdate"
       E que eu selecionei "Sexo" com "M"
       E que eu preenchi "cpf" com "724.164.753-04"
       E que eu preenchi "address" com "Rua Sei Não"
       E que eu preenchi "address_number" com "123"
       E que eu preenchi "address_complement" com "Ap 000"
       E que eu preenchi "address_neighborhood" com "Sei lá qual"
       E que eu preenchi "zipcode" com "60000-000"
       E que eu preenchi "country" com "Brasil"
       E que eu selecionei "Estado" com ""
       E que eu preenchi "city" com "Fortaleza"
       E que eu preenchi "telephone" com "(85)3322-2233"
       E que eu preenchi "cell_phone" com "(85)8888-8888"
    Quando eu clicar em "confirm"
    Então eu deverei ver "Login é muito curto(a) (mínimo: 3 caracteres)"

Cenário: Cadastrar novo usuário e sair logo em seguida
    Dado que estou em "Cadastrar usuario"
       E que eu preenchi "username" com "usuario"
       E que eu preenchi "password" com "123456"
       E que eu preenchi "password_confirmation" com "123456"
       E que eu preenchi "nick" com "usuario"
       E que eu preenchi "email" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "email_confirmation" com "usuario@solar.virtual.ufc.br"
       E que eu preenchi "institution" com "Inst"
       E que eu preenchi "name" com "Usuário do Solar"
       E que eu selecionei a data "13/12/2001" no campo com id "user_birthdate"
       E que eu selecionei "Sexo" com "M"
       E que eu preenchi "cpf" com "724.164.753-04"
       E que eu preenchi "address" com "Rua Sei Não"
       E que eu preenchi "address_number" com "123"
       E que eu preenchi "address_complement" com "Ap 000"
       E que eu preenchi "address_neighborhood" com "Sei lá qual"
       E que eu preenchi "zipcode" com "60000-000"
       E que eu preenchi "country" com "Brasil"
       E que eu selecionei "Estado" com "CE"
       E que eu preenchi "city" com "Fortaleza"
       E que eu preenchi "telephone" com "(85)3322-2233"
       E que eu preenchi "cell_phone" com "(85)8888-8888"
    Quando eu clicar em "confirm"
    Então eu deverei ver "Sair"
        E eu deverei ver "Home"
    Quando eu clicar no link "Sair"
	Então eu deverei ver "Usuário"
    	E eu deverei ver "Senha"
