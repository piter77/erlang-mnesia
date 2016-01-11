%%%-------------------------------------------------------------------
%%% @author piter777
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 3. sty 2016 18:36
%%%-------------------------------------------------------------------
-module(mn_project).
-author("piter777").

%% API
-compile(export_all).

-include_lib("stdlib/include/qlc.hrl").
-include("records.hrl").


init() ->
  mnesia:create_schema([node()]),
  mnesia:start().


createTables() ->
  mnesia:create_table(student,
    [{index, [#student.card_id]},
      {attributes, record_info(fields, student)}]),

  mnesia:create_table(team_leader,
    [{attributes, record_info(fields, team_leader)}]),

  mnesia:create_table(team,
    [{attributes, record_info(fields, team)}]),

  mnesia:create_table(in_project,
    [{type, bag},
    {attributes, record_info(fields, in_project)}]).

%%
%%  "SETTERS"
%%

add_student(Name, Year, CardID) ->
  Fun = fun() ->
    mnesia:write(#student{name=Name,
                          year=Year,
                          card_id=CardID})

        end,
  mnesia:transaction(Fun).

add_project(Name, Id) ->
  F = fun() ->
    mnesia:write(#team{name = Name,
                       id=Id})
        end,
  mnesia:transaction(F).

assign_to_project(Project, Student) ->
  Fun = fun() ->
    mnesia:write(#in_project{student = Student,
                             project = Project})
        end,
  mnesia:transaction(Fun).

add_team_leader(Project, Student) ->
  Fun = fun() ->
    mnesia:write(#team_leader{student = Student,
                              project = Project}),
    mn_project:assign_to_project(Project, Student)
        end,
  mnesia:transaction(Fun).

%%
%% ADDING CONTENT
%%

add_some_people() ->
  mn_project:add_student("Andrzej", 1, 3464323),
  mn_project:add_student("Janusz", 3, 1347126),
  mn_project:add_student("Januszek", 4, 234552234),
  mn_project:add_student("Marek", 2, 646714),
  mn_project:add_student("Krystyna", 3, 0431614),
  mn_project:add_student("Grazyna", 1, 663461),
  mn_project:add_student("Krystian", 3, 1456243),
  mn_project:add_student("Jacek", 1, 234617),
  mn_project:add_student("Mariusz", 2, 236236),
  mn_project:add_student("Karolina", 3, 45362346),
  mn_project:add_student("Andzelika", 2, 2546225).

add_some_project() ->
  mn_project:add_project("Erlang", 1),
  mn_project:add_project("Scala", 2),
  mn_project:add_project("Java", 3),
  mn_project:add_project("C++", 4).

assign_people_to_projects() ->
  mn_project:assign_to_project("Erlang", "Krystyna"),
  mn_project:assign_to_project("Erlang", "Grazyna"),
  mn_project:assign_to_project("Erlang", "Karolina"),
  mn_project:assign_to_project("Erlang", "Janusz"),
  mn_project:assign_to_project("Scala", "Andzelika"),
  mn_project:assign_to_project("Scala", "Marek"),
  mn_project:assign_to_project("Scala", "Jacek"),
  mn_project:assign_to_project("Java", "Mariusz"),
  mn_project:assign_to_project("Java", "Karolina"),
  mn_project:assign_to_project("Java", "Krystian"),
  mn_project:assign_to_project("Java", "Jacek"),
  mn_project:assign_to_project("Java", "Andrzej").

add_teamleaders() ->
  mn_project:add_team_leader("Erlang", "Andrzej"),
  mn_project:add_team_leader("Scala", "Janusz"),
  mn_project:add_team_leader("Java", "Marek"),
  mn_project:add_team_leader("C++", "Januszek").

%%
%% GETTERS
%%

get_students() ->
  F = fun() ->
    Q = qlc:q([{E#student.name, E#student.year, E#student.card_id} || E <- mnesia:table(student)]),
    qlc:e(Q)
      end,
  mnesia:transaction(F).

get_year(Year) ->
  F = fun() ->
    Q = qlc:q([{E#student.name, E#student.year} || E <- mnesia:table(student),
      E#student.year == Year]),
    qlc:e(Q)
  end,
  mnesia:transaction(F).

get_projects() ->
  F = fun() ->
    Q = qlc:q([E#team.name || E <- mnesia:table(team)]),
    qlc:e(Q)
      end,
  mnesia:transaction(F).

get_teamleads() ->
  F = fun() ->
    Q = qlc:q([{E#team_leader.student, E#team_leader.project} || E <- mnesia:table(team_leader)]),
    qlc:e(Q)
      end,
  mnesia:transaction(F).

get_participants(Project) ->
  F = fun() ->
    Q = qlc:q([E#in_project.student || E <- mnesia:table(in_project),
      E#in_project.project == Project]),
    qlc:e(Q)
      end,
  mnesia:transaction(F).

%%
%%  EDITING DATABASE
%%

graduate_all() ->
  F = fun() ->
    G = qlc:q([E || E <- mnesia:table(student)]),
    List = qlc:e(G),
    graduate(List)
  end,
  mnesia:transaction(F).

graduate([H|Tail]) ->
  Newyear = H#student.year +1,
  New = H#student{year = Newyear},
  mnesia:write(New),
  1 + graduate(Tail);
graduate([]) ->  0.