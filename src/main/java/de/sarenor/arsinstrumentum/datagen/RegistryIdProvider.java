package de.sarenor.arsinstrumentum.datagen;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import de.sarenor.arsinstrumentum.ArsInstrumentum;
import net.minecraft.core.Registry;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.data.CachedOutput;
import net.minecraft.data.DataProvider;
import net.minecraft.resources.ResourceLocation;
import org.jetbrains.annotations.NotNull;

import java.nio.file.Path;
import java.util.Comparator;
import java.util.concurrent.CompletableFuture;

public class RegistryIdProvider implements DataProvider {
    private final Path output;

    public RegistryIdProvider(Path output) {
        this.output = output;
    }

    @Override
    public CompletableFuture<?> run(CachedOutput cache) {
        JsonObject registries = new JsonObject();
        addIds(registries, "items", BuiltInRegistries.ITEM);
        addIds(registries, "blocks", BuiltInRegistries.BLOCK);
        addIds(registries, "block_entities", BuiltInRegistries.BLOCK_ENTITY_TYPE);
        addIds(registries, "data_components", BuiltInRegistries.DATA_COMPONENT_TYPE);
        return DataProvider.saveStable(cache, registries, output);
    }

    private static void addIds(JsonObject output, String name, Registry<?> registry) {
        JsonArray ids = new JsonArray();
        registry.keySet().stream()
                .filter(id -> ArsInstrumentum.MODID.equals(id.getNamespace()))
                .sorted(Comparator.comparing(ResourceLocation::toString))
                .forEach(id -> ids.add(id.toString()));
        output.add(name, ids);
    }

    @Override
    public @NotNull String getName() {
        return "Ars Instrumentum registry ID dump";
    }
}
