package de.sarenor.arsinstrumentum.datagen;

import com.hollingsworth.arsnouveau.common.crafting.recipes.ImbuementRecipe;
import com.hollingsworth.arsnouveau.common.datagen.ImbuementRecipeProvider;
import com.hollingsworth.arsnouveau.common.datagen.ModDatagen;
import com.hollingsworth.arsnouveau.setup.registry.ItemsRegistry;
import de.sarenor.arsinstrumentum.setup.Registration;
import net.minecraft.data.CachedOutput;
import net.minecraft.data.DataGenerator;
import net.minecraft.world.item.ItemStack;
import net.minecraft.world.item.Items;
import net.minecraft.world.item.crafting.Ingredient;
import net.neoforged.neoforge.common.Tags;
import org.jetbrains.annotations.NotNull;

import java.util.concurrent.CompletableFuture;

public class ImbuementRecipes extends ImbuementRecipeProvider {
    public ImbuementRecipes(DataGenerator generatorIn) {
        super(generatorIn);
    }

    @Override
    public void collectJsons(CachedOutput cache) {
        this.recipes.add((new ImbuementRecipe("fake_wilden_tribute", Ingredient.of(Tags.Items.STORAGE_BLOCKS_DIAMOND), new ItemStack(Registration.FAKE_WILDEN_TRIBUTE.get()), 5000)).withPedestalItem(ItemsRegistry.ARCHMAGE_SPELLBOOK).withPedestalItem(Items.NETHER_STAR).withPedestalItem(Items.TOTEM_OF_UNDYING));
    }

    @Override
    public CompletableFuture<?> run(CachedOutput cache) {
        collectJsons(cache);
        return ModDatagen.registries.thenCompose(registries -> RecipeJsonWriter.writeAll(
                recipes,
                recipe -> net.minecraft.data.DataProvider.saveStable(
                        cache,
                        registries,
                        ImbuementRecipe.CODEC,
                        recipe,
                        RecipeJsonWriter.recipePath(output, "imbuement", "imbuement_" + RecipeJsonWriter.path(recipe.id))
                )
        ));
    }

    public @NotNull String getName() {
        return "Instrumentum Imbuement Recipes";
    }
}
