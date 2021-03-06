
_ = require 'underscore-ext'
Boom = require 'boom'
Hoek = require 'hoek'
mongooseRestHelper = require 'mongoose-rest-helper'

i18n = require '../i18n'

fnUnprocessableEntity = (message = "",data) ->
  return Boom.create 422, message, data

###
Provides methods to set up admin users.
###
module.exports = class AdminMethods

  ###
  Initializes a new instance of the @see AdminMethods class.
  @param {Object} models A collection of models that can be used.
  ###
  constructor:(@models, @userMethods) ->
    Hoek.assert @models,i18n.assertModelsRequired
    Hoek.assert @models,i18n.assertUserMethodsRequired

  ###
  Sets up an account ready for use.
  ###
  setup: (_tenantId, username, email, password, roles, options = {}, cb = ->) =>
    return cb Boom.badRequest( i18n.errorTenantIdRequired) unless _tenantId
    return cb fnUnprocessableEntity( i18n.errorUsernameRequired) unless username
    return cb fnUnprocessableEntity( i18n.errorEmailRequired) unless email
    return cb fnUnprocessableEntity( i18n.errorPasswordRequired) unless password

    if _.isFunction(options)
      cb = options 
      options = {}

    _tenantId = mongooseRestHelper.asObjectId _tenantId

    adminUser =
      _tenantId : _tenantId
      username : username
      password : password
      displayName: 'ADMIN'
      roles: roles || ['admin','serveradmin']
      email : email

    @userMethods.create _tenantId,adminUser,{}, (err, user) =>
      return cb err if err
      cb null, user
