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
%%% @doc Protocol Macros.
%%% @end
%%% Created : 06. Oct 2013 8:45 AM
%%%-------------------------------------------------------------------


-define(COMMANDS, [{0, ping},
                   {1, register},
                   {2, unregister},
                   {3, send},
                   {4, subscribe},
                   {5, unsubscribe},
                   {6, publish}]).

-define(EVENTS, [{0, connection_established},
                 {1, pong},
                 {2, internal_error},
                 {3, bad_request},
                 {4, timeout},
                 {5, action_not_allowed},
                 {6, new_message},
                 {7, channel_not_found},
                 {8, channel_creation_succeeded},
                 {9, channel_already_exist},
                 {10, channel_creation_failed},
                 {11, channel_delete_succeeded},
                 {12, channel_delete_failed},
                 {100, registration_succeeded},
                 {101, registration_failed},
                 {102, registration_already_exist},
                 {103, registration_not_found},
                 {104, registration_denied},
                 {200, unregistration_succeeded},
                 {201, unregistration_failed},
                 {300, sending_succeeded},
                 {301, sending_failed},
                 {400, subscription_succeeded},
                 {401, subscription_already_exist},
                 {402, subscription_not_found},
                 {403, subscription_failed},
                 {500, unsubscription_succeeded},
                 {501, unsubscription_failed},
                 {600, publication_succeeded},
                 {601, publication_failed}]).

-define(RES_CONN_ESTABLISHED(F),
    west_msg_utils:build_msg(
        undefined, "west", "connection_established", undefined, undefined, F)).

-define(RES_PONG(Id, F),
    west_msg_utils:build_msg(
        Id, "west", "pong", undefined, undefined, F)).

-define(RES_INTERNAL_ERROR(Id, F),
    west_msg_utils:build_msg(
        Id, "west", "internal_error", undefined, undefined, F)).

-define(RES_BAD_REQUEST(F),
    west_msg_utils:build_msg(
        undefined, "west", "bad_request", undefined, undefined, F)).

-define(RES_ACTION_NOT_ALLOWED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "action_not_allowed", C, undefined, F)).

-define(RES_CH_NEW_MSG(Id, ET, C, B, F),
    west_msg_utils:build_msg(
        Id, ET, "new_message", C, B, F)).

-define(RES_CH_NOT_FOUND(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_not_found", C, undefined, F)).

-define(RES_CH_CREATION_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_creation_succeeded", C, undefined, F)).

-define(RES_CH_ALREADY_EXIST(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_already_exist", C, undefined, F)).

-define(RES_CH_CREATION_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_creation_failed", C, undefined, F)).

-define(RES_CH_DELETE_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_delete_succeeded", C, undefined, F)).

-define(RES_CH_DELETE_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "channel_delete_failed", C, undefined, F)).

-define(RES_REG_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "registration_succeeded", C, undefined, F)).

-define(RES_REG_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "registration_failed", C, undefined, F)).

-define(RES_REG_ALREADY_EXIST(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "registration_already_exist", C, undefined, F)).

-define(RES_REG_NOT_FOUND(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "registration_not_found", C, undefined, F)).

-define(RES_REG_DENIED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "registration_denied", C, undefined, F)).

-define(RES_UNREG_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "unregistration_succeeded", C, undefined, F)).

-define(RES_UNREG_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "unregistration_failed", C, undefined, F)).

-define(RES_SEND_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "sending_succeeded", C, undefined, F)).

-define(RES_SEND_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "sending_failed", C, undefined, F)).

-define(RES_SUB_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "subscription_succeeded", C, undefined, F)).

-define(RES_SUB_ALREADY_EXIST(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "subscription_already_exist", C, undefined, F)).

-define(RES_SUB_NOT_FOUND(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "subscription_not_found", C, undefined, F)).

-define(RES_SUB_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "subscription_failed", C, undefined, F)).

-define(RES_UNSUB_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "unsubscription_succeeded", C, undefined, F)).

-define(RES_UNSUB_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "unsubscription_failed", C, undefined, F)).

-define(RES_PUB_OK(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "publication_succeeded", C, undefined, F)).

-define(RES_PUB_FAILED(Id, C, F),
    west_msg_utils:build_msg(
        Id, "west", "publication_failed", C, undefined, F)).
