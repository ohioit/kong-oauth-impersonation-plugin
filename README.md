# Kong OAuth Impersonation Plugin

Plugin to allow OAuth users to be impersonated for troubleshooting and
testing purposes. When an API request is proxied for an impersonated authentication,
the upstream headers will be updated such that `x-authenticated-userid` will represent
the user being impersonated and `x-authenticated-actual-userid` will represent the user
originally logging in.

**Note: No access checking is performed on user impersonation beyond verifying the
provision key for the OAuth plugin. This should be handled in your app or integration.**

The impersonation is stored on *the access token being used*. When that access token
expires, the impersonation will stop as well.

## Installation

For now, you'll have to clone this repository and use `luarocks make`
to install it into Kong. See the
[custom plugin documentation](https://getkong.org/docs/0.10.x/plugin-development/distribution/)
for details.

## Usage

After installing the plugin, add it to an API or globally. There are no configuration
options. The plugin exposes some new APIs:

**POST /apis/:api/oauth2/impersonate/:targetUser**: Impersonate `targetUser` on the
OAuth 2.0 token making the request. Note that `api` must match an API for which the
current OAuth token is valid. The token may be specified in the header or the
`access_token` request parameter. The `provision_key` may be specified as a URL
parameter or a POST parameter and must match the provision key for the OAuth 2.0
plugin.

**DELETE /apis/:api/oauth2/impersonate**: Stop impersonating any user currently
being impersonated. This simply clears impersonation and reset the access token
back to it's default state.

**DELETE /apis/:api/oauth2/impersonate/:targetUser**: Identical to the previous
endpoint, `targetUser` is ignored. This is retained for backwards compatibility.

## Execution Priority

This plugin runs after all authentication plugins but before both request
transformers _and_ the [Userinfo Plugin](https://github.com/ohioit/kong-userinfo-plugin)
so that impersonated users can have their information retrieved. Note that,
at this time, the actual user's information is not retrieved.