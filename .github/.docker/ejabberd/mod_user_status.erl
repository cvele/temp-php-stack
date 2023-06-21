-module(mod_user_status).
-author('vladimir@ferdinand.rs').

-behaviour(gen_mod).

-export([start/2,
     depends/2,
     mod_options/1,
     mod_opt_type/1,
     mod_doc/0,
     stop/1,
	 send_unavailable_notice/4,
	 send_available_notice/4]).

-define(PROCNAME, ?MODULE).

-include("xmpp.hrl").
-include("logger.hrl").

stop(Host) ->
    ?INFO_MSG("Stopping mod_user_status", [] ),
    ejabberd_hooks:delete(unset_presence_hook, Host, ?MODULE, send_unavailable_notice, 10),
    ejabberd_hooks:delete(set_presence_hook, Host, ?MODULE, send_available_notice, 10),
    ok.

start(_Host, _Opt) ->
  ?INFO_MSG("Starting mod_user_status", [] ),
  inets:start(),
  ?INFO_MSG("HTTP client started", []),
  ejabberd_hooks:add(unset_presence_hook, _Host, ?MODULE, send_unavailable_notice, 10),
  ejabberd_hooks:add(set_presence_hook, _Host, ?MODULE, send_available_notice, 10),
  ok.


depends(_Host, _Opts) ->
  [].

mod_options(_Host) ->
  [{auth_token, <<"secret">>},
  {post_url_unavailable, <<"http://example.com/notify">>},
  {post_url_available, <<"http://example.com/notify">>}].

mod_opt_type(auth_token) ->
  fun iolist_to_binary/1;
mod_opt_type(post_url_unavailable) ->
  fun iolist_to_binary/1;
mod_opt_type(post_url_available) ->
  fun iolist_to_binary/1.

send_unavailable_notice(User, Server, _Resource, _Status) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url_unavailable),
    if (Token /= "") ->
	      Sep = "&",
	      Post = [
	        "user=", User, Sep,
	        "access_token=", Token ],
        Request = {binary_to_list(PostUrl), [{"Authorization", binary_to_list(Token)}], "application/x-www-form-urlencoded", list_to_binary(Post)},
        httpc:request(post, Request,[],[]),
	      ok;
	    true ->
	      ok
    end.

send_available_notice(User, Server, _Resource, _Packet) ->
    Token = gen_mod:get_module_opt(Server, ?MODULE, auth_token),
    PostUrl = gen_mod:get_module_opt(Server, ?MODULE, post_url_available),
    if (Token /= "") ->
				Sep = "&",
				Post = [
					"user=", User, Sep,
					"access_token=", Token ],
        Request = {binary_to_list(PostUrl), [{"Authorization", binary_to_list(Token)}], "application/x-www-form-urlencoded", list_to_binary(Post)},
        httpc:request(post, Request,[],[]),
				ok;
			true ->
				ok
    end.

mod_doc() ->
    #{desc =>
          "Pushes available/unavailable status to http",
      opts =>
          [{auth_token,
            #{value => "auth_token",
              desc =>
                  "This is for API call to authenticate"}},
           {post_url_available,
            #{value => "https://example.com/notify",
              desc =>
                  "post_url_available"}},
           {post_url_unavailable,
            #{value => "https://example.com/notify",
              desc =>
                  "post_url_unavailable"}}]}.
