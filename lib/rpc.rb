# const assert = require('assert');

# const httpx = require('httpx');
# const kitx = require('kitx');
# const JSON = require('json-bigint');
require 'date'

def firstLetterUpper(str)
  return str[0].upcase + str[1..-1]
end

# def formatParams(params)
#   keys = Object.keys(params);
#   newParams = {};
#   for (var i = 0; i < keys.length; i++) {
#     var key = keys[i];
#     newParams[firstLetterUpper(key)] = params[key];
#   }
#   return newParams;
# end

def pad2(n)
  if n < 10 then
    return '0' + String(n)
  else
    return String(n)
  end
end

def timestamp
  date = Time.now
  _YYYY = date.year
  _MM = pad2(date.month)
  _DD = pad2(date.day)
  _HH = pad2(date.hour)
  mm = pad2(date.min)
  ss = pad2(date.sec)
  # 删除掉毫秒部分
  return "#{_YYYY}-#{_MM}-#{_DD}T#{_HH}:#{mm}:#{ss}Z";
end

# def encode(str)
#   result = encodeURIComponent(str);

#   return result.replace(/\!/g, '%21')
#    .replace(/\'/g, '%27')
#    .replace(/\(/g, '%28')
#    .replace(/\)/g, '%29')
#    .replace(/\*/g, '%2A');
# end

# def replaceRepeatList(target, key, repeat)
#   for item in repeat
#     if (item && typeof item === 'object') then
#       const keys = Object.keys(item);
#       for currentKey in keys
#         target[`${key}.${i + 1}.${currentKey}`] = item[currentKey];
#       }
#     else
#       target[`${key}.${i + 1}`] = item;
#     end
#   end
# end

# def flatParams(params)
#   var target = {};
#   var keys = Object.keys(params);
#   for (let i = 0; i < keys.length; i++) {
#     var key = keys[i];
#     var value = params[key];
#     if (Array.isArray(value)) then
#       replaceRepeatList(target, key, value);
#     else
#       target[key] = value;
#     end
#   }
#   return target;
# end

# def normalize(params)
#   var list = [];
#   var flated = flatParams(params);
#   var keys = Object.keys(flated).sort();
#   for (let i = 0; i < keys.length; i++) {
#     var key = keys[i];
#     var value = flated[key];
#     list.push([encode(key), encode(value)]); #push []
#   }
#   return list;
# end

# def canonicalize(normalized)
#   var fields = [];
#   for (var i = 0; i < normalized.length; i++) {
#     var [key, value] = normalized[i];
#     fields.push(key + '=' + value);
#   }
#   return fields.join('&');
# end

# class RPCClient
#   def initialize(config, verbose)
#     assert(config, 'must pass "config"');
#     assert(config.endpoint, 'must pass "config.endpoint"');
#     if (!config.endpoint.startsWith('https:#') &&
#       !config.endpoint.startsWith('http:#')) then
#       throw new Error(`"config.endpoint" must starts with 'https:#' or 'http:#'.`);
#     end
#     assert(config.apiVersion, 'must pass "config.apiVersion"');
#     assert(config.accessKeyId, 'must pass "config.accessKeyId"');
#     accessKeySecret = config.secretAccessKey || config.accessKeySecret;
#     assert(accessKeySecret, 'must pass "config.accessKeySecret"');

#     if (config.endpoint.endsWith('/')) then
#       config.endpoint = config.endpoint.slice(0, -1);
#     end

#     @endpoint = config.endpoint;
#     @apiVersion = config.apiVersion;
#     @accessKeyId = config.accessKeyId;
#     @accessKeySecret = accessKeySecret;
#     @securityToken = config.securityToken;
#     @verbose = verbose === true;
#     # 非 codes 里的值，将抛出异常
#     @codes = new Set([200, '200', 'OK', 'Success']);
#     if (config.codes) then
#       # 合并 codes
#       for (var elem of config.codes) {
#         @codes.add(elem);
#       }
#     end

#     @opts = config.opts || {};

#     httpModule = @endpoint.startsWith('https:#')
#       ? require('https') : require('http');
#     @keepAliveAgent = new httpModule.Agent({
#       keepAlive: true,
#       keepAliveMsecs: 3000
#     });
#   end

#   def request(action, params = {}, opts = {})
#     # 1. compose params and opts
#     opts = Object.assign({}, @opts, opts);

#     # format action until formatAction is false
#     if (opts.formatAction !== false) then
#       action = firstLetterUpper(action);
#     end

#     # format params until formatParams is false
#     if (opts.formatParams !== false) then
#       params = formatParams(params);
#     end
#     var defaults = @_buildParams();
#     params = Object.assign({Action: action}, defaults, params);

#     # 2. caculate signature
#     var method = (opts.method || 'GET').toUpperCase();
#     var normalized = normalize(params);
#     var canonicalized = canonicalize(normalized);
#     # 2.1 get string to sign
#     var stringToSign = `${method}&${encode('/')}&${encode(canonicalized)}`;
#     # 2.2 get signature
#     const key = @accessKeySecret + '&';
#     var signature = kitx.sha1(stringToSign, key, 'base64');
#     # add signature
#     normalized.push(['Signature', encode(signature)]);
#     # 3. generate final url
#     const url = opts.method === 'POST' ? `${@endpoint}/` : `${@endpoint}/?${canonicalize(normalized)}`;
#     # 4. send request
#     var entry = {
#       url: url,
#       request: null,
#       response: null
#     };

#     if (opts && !opts.agent) then
#       opts.agent = @keepAliveAgent;
#     end

#     if (opts.method === 'POST') then
#       opts.headers = {};
#       opts.headers['content-type'] = 'application/x-www-form-urlencoded';
#       opts.data = canonicalize(normalized);
#     end

#     return httpx.request(url, opts).then((response) => {
#       entry.request = {
#         headers: response.req._headers
#       };
#       entry.response = {
#         statusCode: response.statusCode,
#         headers: response.headers
#       };

#       return httpx.read(response);
#     }).then((buffer) => {
#       var json = JSON.parse(buffer);
#       if (json.Code && !@codes.has(json.Code)) {
#         var err = new Error(`${json.Message}, URL: ${url}`);
#         err.name = json.Code + 'Error';
#         err.data = json;
#         err.code = json.Code;
#         err.url = url;
#         err.entry = entry;
#         return Promise.reject(err);
#       }

#       if (@verbose) {
#         return [json, entry];
#       }

#       return json;
#     });
#   end

#   def _buildParams
#     var defaultParams = {
#       Format: 'JSON',
#       SignatureMethod: 'HMAC-SHA1',
#       SignatureNonce: kitx.makeNonce,
#       SignatureVersion: '1.0',
#       Timestamp: timestamp,
#       AccessKeyId: @accessKeyId,
#       Version: @apiVersion,
#     };
#     if (@securityToken) then
#       defaultParams.SecurityToken = @securityToken;
#     end
#     return defaultParams;
#   end
# end
