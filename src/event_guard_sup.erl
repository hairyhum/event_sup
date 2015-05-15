-module(event_guard_sup).

-behaviour(supervisor).

-export([start_link/1, init/1, add_sup_handler/3]).

-spec start_link(ManagerName) -> {ok, pid()} | ignore | {error, term()}
  when ManagerName :: atom().
start_link(ManagerName) when is_atom(ManagerName) ->
  SupervisorName = sup_name(ManagerName),
  supervisor:start_link({local, SupervisorName}, ?MODULE, [ManagerName]).

init([ManagerName]) ->
  Children = [
    {event_guard, {event_guard, start_link, [ManagerName]},
          permanent, 5000, worker, [event_guard]}
  ],
  {ok, { {simple_one_for_one, 10, 60}, Children } }.

add_sup_handler(ManagerName, Handler, Args) ->
  supervisor:start_child(sup_name(ManagerName), [Handler, Args]).

sup_name(ManagerName) ->
  list_to_atom(atom_to_list(ManagerName) ++ "_guard_sup").