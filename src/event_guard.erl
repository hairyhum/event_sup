-module(event_guard).
-behaviour(gen_server).
-export([start_link/3]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-record(state, {event, module, config}).

start_link(ManagerName, Handler, Args) ->
  gen_server:start_link(?MODULE, [ManagerName, Handler, Args], []).

init([ManagerName, Handler, Args]) ->
    ok = gen_event:add_sup_handler(ManagerName, Handler, Args),
    {ok, #state{module=Handler}}.

handle_info({gen_event_EXIT, Handler, normal}, #state{module=Handler} = State) ->
  {stop, normal, State};
handle_info({gen_event_EXIT, Handler, shutdown}, #state{module=Handler} = State) ->
  {stop, normal, State};
handle_info({gen_event_EXIT, Handler, Reason}, #state{module=Handler} = State) ->
  {stop, {handler_exit, Reason}, State}.

handle_call(_, _From, State) ->
  {ok, ok, State}.
 
handle_cast(_, State) ->
  {ok, State}.
 
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
 
terminate(_Reason, _State) ->
  ok.