Feature: Pruebas de Regresion E2E para API Billetera Digital - PRACTICA CALIFICADA KARATE

  Background:
    * def getRandomPhone =
      """
      function() {
        var num = '9';
        for (var i = 0; i < 8; i++) {
          num += Math.floor(Math.random() * 10);
        }
        return num;
      }
      """

  Scenario: Flujo E2E Completo: Registro, Deposito, Transferencia, Validacion en Receptor y Administrador
    * def cellEmisor = getRandomPhone()
    * def cellReceptor = getRandomPhone()


    Given url host + ':4001/auth/v1/register'
    And header x-channel = 'WEB'
    And request { phone: '#(cellEmisor)', fullName: 'Emisor Test', email: '#("emisor_" + cellEmisor + "@test.com")', pin: '123456' }
    When method post
    Then status 201
    * def idEmisor = response.user.id

    Given url host + ':4001/auth/v1/register'
    And header x-channel = 'WEB'
    And request { phone: '#(cellReceptor)', fullName: 'Receptor Test', email: '#("receptor_" + cellReceptor + "@test.com")', pin: '123456' }
    When method post
    Then status 201
    * def idReceptor = response.user.id


    Given url host + ':4001/auth/v1/login'
    And header x-channel = 'WEB'
    And request { phone: '#(cellEmisor)', pin: '123456' }
    When method post
    Then status 200
    * def tokenEmisor = response.token


    Given url host + ':4001/auth/v1/login'
    And header x-channel = 'WEB'
    And request { phone: '#(cellReceptor)', pin: '123456' }
    When method post
    Then status 200
    * def tokenReceptor = response.token


    Given url host + ':4002/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenEmisor
    And header x-channel = 'WEB'
    And request { amount: 1000.00 }
    When method post
    Then status 200
    And match response.newBalance == 1000.00


    Given url host + ':4002/wallet/v1/deposit'
    And header Authorization = 'Bearer ' + tokenReceptor
    And header x-channel = 'WEB'
    And request { amount: 200.00 }
    When method post
    Then status 200
    And match response.newBalance == 200.00

    * def saldoInicialEmisor = 1000.00
    * def saldoInicialReceptor = 200.00


    Given url host + ':4001/auth/v1/register'
    And header x-channel = 'WEB'
    And request { phone: '#(cellEmisor)', fullName: 'Emisor Duplicado', email: '#("dup_" + cellEmisor + "@test.com")', pin: '123456' }
    When method post
    Then status 409



    Given url host + ':4001/auth/v1/login'
    And header x-channel = 'WEB'
    And request { phone: '#(cellEmisor)', pin: '123456' }
    When method post
    Then status 200
    * def currentAuthTokenEmisor = response.token


    Given url host + ':4003/transaction/v1/transfer'
    And header Authorization = 'Bearer ' + currentAuthTokenEmisor
    And header x-channel = 'WEB'
    And request { recipientId: '#(idReceptor)', recipientPhone: '#(cellReceptor)', amount: 450.00, pin: '123456', description: 'Pago de Servicios' }
    When method post
    Then status 200
    And match response.status == 'COMPLETED'

    * def transactionCode = response.transactionId

    Given url host + ':4002/wallet/v1/balance'
    And header Authorization = 'Bearer ' + currentAuthTokenEmisor
    And header x-channel = 'WEB'
    When method get
    Then status 200

    * def saldoEsperadoEmisor = saldoInicialEmisor - 450.00
    And match response.balance == saldoEsperadoEmisor




    Given url host + ':4001/auth/v1/login'
    And header x-channel = 'WEB'
    And request { phone: '#(cellReceptor)', pin: '123456' }
    When method post
    Then status 200
    * def currentTokenReceptor = response.token

    Given url host + ':4002/wallet/v1/balance'
    And header Authorization = 'Bearer ' + currentTokenReceptor
    And header x-channel = 'WEB'
    When method get
    Then status 200

    * def saldoEsperadoReceptor = saldoInicialReceptor + 450.00
    And match response.balance == saldoEsperadoReceptor

    Given url host + ':4003/transaction/v1/history'
    And header Authorization = 'Bearer ' + currentTokenReceptor
    And header x-channel = 'WEB'
    When method get
    Then status 200

    And match response[0].id == transactionCode



    Given url host + ':4004/admin/v1/transactions/' + transactionCode
    And header x-channel = 'WEB'
    When method get
    Then status 200
    And match response.id == transactionCode
    And match response.amount == 450.00
    And match response.status == 'COMPLETED'