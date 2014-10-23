angular.module('loomioApp').service 'FileUploadService',
  class FileUploadService
    constructor: (@$http) ->
      @$http.post("/api/v1/attachments/credentials").then (response) =>
        data = response.data
        @url       = data.url
        @acl       = data.acl
        @key       = data.key
        @policy    = data.policy
        @signature = data.signature
        @accessKey = data.AWSAccessKeyId

    getParams: (attachment) ->
      url:    @url
      method: 'POST'
      file:   attachment
      data:
        utf8:           '✓',
        acl:            @acl,
        policy:         @policy,
        signature:      @signature,
        AWSAccessKeyId: @accessKey,
        key:            @key.replace('${filename}', attachment.name),
        "Content-Type": attachment.type or 'application/octet-stream'
