-module(mod_pubsub_cache).

-include("mongoose_logger.hrl").

%%====================================================================
%% Behaviour callbacks
%%====================================================================

%% ------------------------ Backend start/stop ------------------------

-callback start() -> ok.

-callback stop() -> ok.

-callback create_table() -> ok | {error, Reason :: term()}.

-callback delete_table() -> ok | {error, Reason :: term()}.

-callback upsert_last_item(Nidx :: mod_pubsub:nodeIdx(),
                           ItemID :: mod_pubsub:itemId(),
                           Publisher::jid:ljid(),
                           Payload::mod_pubsub:payload()) -> ok | {error, Reason :: term()}.

-callback delete_last_item(Nidx :: mod_pubsub:nodeIdx()) -> ok | {error, Reason :: term()}.

-callback get_last_item(Nidx :: mod_pubsub:nodeIdx()) -> [mod_pubsub:pubsubLastItem()] | {error, Reason :: term()}.

