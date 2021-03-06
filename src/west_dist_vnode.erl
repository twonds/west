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
%%% @doc A vnode to handle commands for WEST.  The vnode requests will
%%%      be hashed on Bucket and Key and will use a coordinator to
%%%      enforce N/R/W values.
%%% @see <a href="http://basho.com/where-to-start-with-riak-core"></a>
%%% @end
%%% Created : 04. Nov 2013 8:47 PM
%%%-------------------------------------------------------------------
-module(west_dist_vnode).

-behaviour(riak_core_vnode).

%% riak_core_vnode API
-export([start_vnode/1,
         init/1,
         terminate/2,
         handle_command/3,
         is_empty/1,
         delete/1,
         handle_handoff_command/3,
         handoff_starting/2,
         handoff_cancelled/1,
         handoff_finished/2,
         handle_handoff_data/2,
         encode_handoff_item/2,
         handle_coverage/4,
         handle_exit/3]).

%% API
-export([cmd/3]).

-include_lib("riak_core/include/riak_core_vnode.hrl").

%% VNode State
-record(state, {partition, machine_id, last_timestamp}).

%% Internal
-define(MASTER, west_dist_vnode_master).
-define(sync(PrefList, Command, Master),
    riak_core_vnode_master:sync_command(PrefList, Command, Master)).

%%%===================================================================
%%% API
%%%===================================================================

%%--------------------------------------------------------------------
%% @spec start_vnode(I) -> Reply :: term()
%%
%% Types:
%%    I = any()
%%
%% @doc
%% Starts the vnode
%%
%% @end
%%--------------------------------------------------------------------
start_vnode(I) ->
    riak_core_vnode_master:get_vnode_pid(I, ?MODULE).

%%--------------------------------------------------------------------
%% @spec cmd(PrefList, ReqID, CallbackSpec) -> Reply :: term()
%%
%% Types:
%%    PrefList = any()
%%    ReqID = Hash :: integer() >= 0
%%    CallbackSpec = {Mod :: atom(), Fun :: atom(), Args :: list()}
%%
%% @doc
%% Execute the given command applying the callback function. This
%% callback can be an operation like:
%% [reg, unreg, send, sub, unsub, pub].
%%
%% PrefList: Riak Core preflist.
%% ReqID: The request id so the caller can verify the response.
%% Ref: Unique reference to the GS that will be created.
%% Key: Key which the GS will be registered.
%% CallbackSpec: Callback specification. This will applied when
%%               messages arrives. If `Mod' is `none', the callback
%%               will be treated as a fun.
%%
%% @end
%%--------------------------------------------------------------------
cmd(PrefList, ReqID, CallbackSpec) ->
    riak_core_vnode_master:command(PrefList,
                                   {ReqID, CallbackSpec},
                                   {fsm, undefined, self()},
                                   ?MASTER).

%%%===================================================================
%%% VNode Callbacks
%%%===================================================================

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Init the VNode.
%%
%% @end
%%--------------------------------------------------------------------
init([Partition]) ->
    TS = erlang:now(),
    %% This could get ugly if you expect them to be unique across data
    %% centers, or if you have more than 1024 partitions
    <<MachineID:10/bits, _Rest/bits>> = <<Partition:160/integer>>,
    {ok, #state{partition=Partition, machine_id=MachineID, last_timestamp=TS}}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handle ping command - for verification purposes.
%%
%% @end
%%--------------------------------------------------------------------
handle_command(ping, _Sender, State) ->
    {reply, {pong, State#state.partition}, State};

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Handle received command. Applies the callback function.
%%
%% @end
%%--------------------------------------------------------------------
handle_command({ReqID, {M, F, A}}, _Sender, State) ->
    Reply = case M of
                none when is_function(F) ->
                    apply(F, A);
                _ ->
                    apply(M, F, A)
            end,
    {reply, {ok, ReqID, Reply}, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handle_handoff_command(_Message, _Sender, State) ->
    %% Delay a little to naively avoid ID collisions
    timer:sleep(1000),
    {forward, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handoff_starting(_TargetNode, _State) ->
    {true, _State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handoff_cancelled(State) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handoff_finished(_TargetNode, State) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handle_handoff_data(_Data, State) ->
    {reply, ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
encode_handoff_item(_ObjectName, _ObjectValue) ->
    <<>>.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
is_empty(State) ->
    {true, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
delete(State) ->
    {ok, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handle_coverage(_Req, _KeySpaces, _Sender, State) ->
    {stop, not_implemented, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
handle_exit(_Pid, Reason, State) ->
    {stop, Reason, State}.

%%--------------------------------------------------------------------
%% @private
%% @doc
%% Not handled.
%%
%% @end
%%--------------------------------------------------------------------
terminate(_Reason, _State) ->
    ok.
