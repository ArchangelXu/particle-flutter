package network.particle.flutter.bridge.model;

import com.connect.common.model.DAppMetadata;
import com.google.gson.annotations.SerializedName;


public class InitData {

    @SerializedName("chain_name")
    public String chainName;

    @SerializedName("chain_id")
    public int chainId;

    @SerializedName("chain_id_name")
    public String chainIdName;

    @SerializedName("env")
    public String env;

    @SerializedName("metadata")
    public DAppMetadata metadata;

    @SerializedName("rpc_url")
    public RpcUrl rpcUrl;
}
