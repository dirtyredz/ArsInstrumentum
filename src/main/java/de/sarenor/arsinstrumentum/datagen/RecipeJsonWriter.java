package de.sarenor.arsinstrumentum.datagen;

import de.sarenor.arsinstrumentum.ArsInstrumentum;
import net.minecraft.resources.ResourceLocation;

import java.nio.file.Path;
import java.util.List;
import java.util.concurrent.CompletableFuture;
import java.util.function.Function;

final class RecipeJsonWriter {
    private RecipeJsonWriter() {
    }

    static Path recipePath(Path output, String category, String fileName) {
        return output.resolve("data")
                .resolve(ArsInstrumentum.MODID)
                .resolve("recipe")
                .resolve(category)
                .resolve(fileName + ".json");
    }

    static <T> CompletableFuture<?> writeAll(List<T> recipes, Function<T, CompletableFuture<?>> writer) {
        CompletableFuture<?>[] writes = recipes.stream()
                .map(writer)
                .toArray(CompletableFuture[]::new);
        return CompletableFuture.allOf(writes);
    }

    static String path(ResourceLocation id) {
        return id.getPath();
    }
}
