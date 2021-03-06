%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 SyncFree Consortium.  All Rights Reserved.
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

%% @doc Intersection test.

-module(lasp_intersection_test).
-author("Christopher Meiklejohn <cmeiklejohn@basho.com>").

-export([test/1]).

-ifdef(TEST).

-export([confirm/0]).

-define(HARNESS, (rt_config:get(rt_harness))).

-include_lib("eunit/include/eunit.hrl").

confirm() ->
    [Nodes] = rt:build_clusters([1]),
    lager:info("Nodes: ~p", [Nodes]),
    Node = hd(Nodes),

    lager:info("Remotely loading code on node ~p", [Node]),
    ok = lasp_test_helpers:load(Nodes),
    lager:info("Remote code loading complete."),

    ok = lasp_test_helpers:wait_for_cluster(Nodes),

    ?assertEqual({ok, [3,a]},
                 rpc:call(Node, ?MODULE, test, [lasp_orset])),

    ?assertEqual({ok, [3,a]},
                 rpc:call(Node, ?MODULE, test, [lasp_orset_gbtree])),

    lager:info("Done!"),

    pass.

-endif.

test(Type) ->
    %% Create initial sets.
    {ok, S1} = lasp:declare(Type),
    {ok, S2} = lasp:declare(Type),

    %% Create output set.
    {ok, S3} = lasp:declare(Type),

    %% Populate initial sets.
    {ok, _} = lasp:update(S1, {add_all, [1,2,3,a]}, a),
    {ok, _} = lasp:update(S2, {add_all, [a,b,c,3]}, a),

    %% Apply intersection.
    ok = lasp:intersection(S1, S2, S3),

    %% Sleep.
    timer:sleep(400),

    %% Read intersection.
    {ok, {_, _, _, Intersection0}} = lasp:read(S3, undefined),

    %% Read intersection value.
    Intersection = Type:value(Intersection0),

    {ok, Intersection}.
