-module(event_sup).
-behaviour(supervisor).

-export([start_link/2, init/1]).

-spec start_link(ManagerName, Handlers) -> {ok, pid()} | ignore | {error, term()}
  when ManagerName :: atom(), 
       Handlers :: [{Handler, Args}], 
       Handler :: module() | {module(), term()},
       Args :: [term()].
start_link(ManagerName, Handlers) when is_atom(ManagerName), is_list(Handlers) ->
  SupervisorName = list_to_atom(atom_to_list(ManagerName) ++ "_sup"),
  case supervisor:start_link({local, SupervisorName}, ?MODULE, [ManagerName]) of
    {ok, Pid} ->
      lists:foreach(
        fun({Handler, Args}) ->
          add_sup_handler(ManagerName, Handler, Args)
        end,
        Handlers),
      {ok, Pid};
    Other -> Other
  end.

init([ManagerName]) ->
  Children = [
    {ManagerName, {gen_event, start_link, [{local, ManagerName}]},
            permanent, 5000, worker, [dynamic]},
    {event_guard_sup, {event_guard_sup, start_link, [ManagerName]},
        permanent, 5000, supervisor, [event_guard_sup]}
  ],
  {ok, { {one_for_one, 1000, 10}, Children} }.


add_sup_handler(ManagerName, Handler, Args) ->
  event_guard_sup:add_sup_handler(ManagerName, Handler, Args).