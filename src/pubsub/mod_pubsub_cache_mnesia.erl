-module(mod_pubsub_cache_mnesia).

-include("pubsub.hrl").
-include("jlib.hrl").

-export([start/0, stop/0]).

-export([
    create_table/0,
    delete_table/0,
    upsert_last_item/4,
    get_last_item/1,
    delete_last_item/1]).

%% ------------------------ Backend start/stop ------------------------

-spec start() -> ok.
start() ->
    create_table().

-spec stop() -> ok.
stop() ->
    delete_table().

-spec create_table() -> ok | {error, Reason :: term()}.
create_table() ->
    QueryResult = mnesia:create_table(
        pubsub_last_item,
        [
            {ram_copies, [node()]},
            {attributes, record_info(fields, pubsub_last_item)}
        ]),
        mnesia:add_table_copy(pubsub_last_item, node(), ram_copies),
        process_query_result(QueryResult).

-spec delete_table() -> ok | {error, Reason :: term()}.
delete_table() ->
    QueryResult = mnesia:del_table_copy(pubsub_last_item, node()),
    process_query_result(QueryResult).

-spec upsert_last_item(Nidx :: mod_pubsub:nodeIdx(),
                 ItemID :: mod_pubsub:itemId(),
                 Publisher::jid:ljid(),
                 Payload::mod_pubsub:payload()) -> ok | {error, Reason :: term()}.
upsert_last_item(Nidx, ItemId, Publisher, Payload) ->
    try mnesia:dirty_write(
        {pubsub_last_item,
        Nidx,
        ItemId,
        {os:timestamp(),
            jid:to_lower(jid:to_bare(Publisher))},
        Payload}
    ) of
        ok -> ok
    catch
        exit:{aborded, Reason} -> {error, Reason}
    end.

-spec get_last_item(Nidx :: mod_pubsub:nodeIdx()) -> [mod_pubsub:pubsubLastItem()] | {error, Reason :: term()}.
get_last_item(Nidx) ->
    try mnesia:dirty_read({pubsub_last_item, Nidx}) of
        L when is_list(L) -> L
    catch
        exit:{aborded, Reason} -> {error, Reason}
    end.

-spec delete_last_item(Nidx :: mod_pubsub:nodeIdx()) -> ok | {error, Reason :: term()}.
delete_last_item(Nidx) ->
    try mnesia:dirty_delete({pubsub_last_item, Nidx}) of
        ok -> ok
    catch
        exit:{aborded, Reason} -> {error, Reason}
    end.

%% ------------------------ Helpers ----------------------------

process_query_result({atomic, ok}) -> ok;
process_query_result({aborted, Reason}) -> {error, Reason}.
