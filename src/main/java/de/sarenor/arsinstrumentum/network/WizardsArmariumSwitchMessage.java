package de.sarenor.arsinstrumentum.network;

import com.hollingsworth.arsnouveau.common.network.AbstractPacket;
import de.sarenor.arsinstrumentum.ArsInstrumentum;
import de.sarenor.arsinstrumentum.items.curios.armarium.WizardsArmarium;
import de.sarenor.arsinstrumentum.utils.CuriosUtil;
import net.minecraft.network.FriendlyByteBuf;
import net.minecraft.network.RegistryFriendlyByteBuf;
import net.minecraft.network.codec.StreamCodec;
import net.minecraft.network.protocol.common.custom.CustomPacketPayload;
import net.minecraft.server.MinecraftServer;
import net.minecraft.server.level.ServerPlayer;
import org.jetbrains.annotations.NotNull;

public class WizardsArmariumSwitchMessage extends AbstractPacket {

    public static final StreamCodec<RegistryFriendlyByteBuf, WizardsArmariumSwitchMessage> CODEC = StreamCodec.ofMember(WizardsArmariumSwitchMessage::toBytes, WizardsArmariumSwitchMessage::new);
    public static final CustomPacketPayload.Type<WizardsArmariumSwitchMessage> TYPE = new CustomPacketPayload.Type<>(ArsInstrumentum.prefix("wizards_armarium_switch"));


    public WizardsArmariumSwitchMessage() {
    }

    //Decoder
    public WizardsArmariumSwitchMessage(FriendlyByteBuf buf) {
    }

    //Encoder
    public void toBytes(FriendlyByteBuf buf) {
    }

    @Override
    public void onServerReceived(MinecraftServer minecraftServer, ServerPlayer player) {
        if (player != null && CuriosUtil.isArmariumEquipped(player)) {
            WizardsArmarium.handleArmariumSwitch(player);
        }
    }

    @Override
    public @NotNull Type<? extends CustomPacketPayload> type() {
        return TYPE;
    }
}
