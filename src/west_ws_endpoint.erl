%% -------------------------------------------------------------------
%%
%% Copyright (c) 2013 Carlos Andres Bolaños, Inc. All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

%%%-------------------------------------------------------------------
%%% @author Carlos Andres Bolaños R.A. <cabolanos@niagarasystems.co>
%%% @copyright (C) 2013, <Carlos Andres Bolaños>, All Rights Reserved.
%%% @doc This module handle the WS initial handshaking. This module
%%%      was originally taken from `yaws' WS examples.
%%% @end
%%% Created : 03. Oct 2013 9:57 AM
%%%-------------------------------------------------------------------
-module(west_ws_endpoint).

%% API
-export([out/1]).

-include_lib("stdlib/include/erl_bits.hrl").
-include_lib("stdlib/include/qlc.hrl").
-include_lib("yaws/include/yaws_api.hrl").
-include("west.hrl").

out(A) ->
    %% HTTP WebSocket handshake callback
    case application:get_env(west, http_ws_handshake_callback) of
        {ok, {Mod, Fun}} when Mod =/= none, Fun =/= none ->
            ?LOG_INFO("apply(~p, ~p)~n", [Mod, Fun]),
            case apply(Mod, Fun, [A]) of
                ok ->
                    upgrade_http_to_websocket(A);
                {Rc, Rp} when is_integer(Rc), is_list(Rp) ->
                    [{status, Rc}, {html, iolist_to_binary(Rp)}];
                _ ->
                    [{status, 401}, {html, <<>>}]
            end;
        _ ->
            upgrade_http_to_websocket(A)
    end.

upgrade_http_to_websocket(A) ->
    %% To use the extended version of the basic echo callback, add
    %% 'extversion=true' in the query string.
    CallbackMod = case yaws_api:queryvar(A, "protocol") of
                      {ok, "text"} -> west_ws_text_protocol_handler;
                      {ok, "pb"}   -> west_ws_pb_protocol_handler;
                      _            -> west_ws_json_protocol_handler
                  end,

    %% To enable keepalive timer add 'keepalive=true' in the query string.
    KeepAlive = case yaws_api:queryvar(A, "keepalive") of
                    {ok, "true"} -> true;
                    _            -> false
                end,

    %% To define a keepalive timeout value, add 'timeout=Int' in the query
    %% string.
    Tout = case yaws_api:queryvar(A, "timeout") of
               {ok, Val} ->
                   try
                       list_to_integer(Val)
                   catch
                       _:_ -> infinity
                   end;
               _ ->
                   infinity
           end,

    %% To drop connection when a timeout occured, add 'drop=true' in the query
    %% string.
    Drop = case yaws_api:queryvar(A, "drop") of
               {ok, "true"} -> true;
               _            -> false
           end,

    %% To reject unmasked frames , add 'close_unmasked=true' in the query
    %% string.
    CloseUnmasked = case yaws_api:queryvar(A, "close_unmasked") of
                        {ok, "true"} -> true;
                        _            -> false
                    end,

    %% NOTE: change the line below to
    %%   Opts = [{origin, any}],
    %% if you want to accept calls from any origin.
    Opts = [
            {origin,            any},
            {keepalive,         KeepAlive},
            {keepalive_timeout, Tout},
            {drop_on_timeout,   Drop},
            {close_if_unmasked, CloseUnmasked}
           ],
    {websocket, CallbackMod, Opts}.
