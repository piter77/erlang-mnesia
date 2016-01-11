%%%-------------------------------------------------------------------
%%% @author piter777
%%% @copyright (C) 2016, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 3. sty 2016 18:30
%%%-------------------------------------------------------------------
-author("piter777").

%% TABLES

-record(student,  {name,
                    year,
                    card_id}).

-record(team,    {name,
                  id}).

%% RELATIONS

-record(team_leader, {project,
                      student}).

-record(in_project,  {project,
                      student}).

%-record(sub_project, {project,
%                      child_project}).