context("analyzeResults.R")

data("example_data_only_values")
data("example_design")
test_design <- example_design[which(example_design$group %in% c("1", "2", "3")), ]
test_data <- example_data_only_values[, as.character(test_design$sample)]
group_header <- test_design$group
unique_groups <- unique(group_header)

data("regression_test_nr")
regression_test_ner <- regression_test_nr@ner
# data("regression_test_ner")

sampleReplicateGroups <- regression_test_nr@nds@sampleReplicateGroups
normMatrices <- getNormalizationMatrices(regression_test_nr)
anova_pvalues <- calculateANOVAPValues(
    normMatrices, 
    sampleReplicateGroups, 
    categoricalANOVA=FALSE)

test_that("calculateCorrSum gives same Pearson output", {

    expected_group_pearson <- c(
        0.9890682, 0.9885302, 0.9972236, 
        0.9937719, 0.9976159, 0.9948526, 
        0.6108868, 0.9951509, 0.5691397
    )
    
    pear_out <- calculateCorrSum(test_data, group_header, unique_groups, "pearson")
    expect_that(
        all.equal(
            expected_group_pearson,
            round(pear_out, 7)
        ),
        is_true()
    )
    

})

test_that("calculateCorrSum gives same Spearman output", {

    expected_group_spearman <- c(
        0.9234304, 0.9665739, 0.9497886,
        0.9686747, 0.9551886, 0.9420609, 
        0.9250426, 0.9549601, 0.9315987
    )
    
    spear_out <- calculateCorrSum(test_data, group_header, unique_groups, "spearman")
    expect_that(
        all.equal(
            expected_group_spearman,
            round(spear_out, 7)
        ),
        is_true()
    )
})

test_that("calculateReplicateCV", {
    
    expected_out <- regression_test_ner@avgcvmem
    out <- calculateReplicateCV(normMatrices, sampleReplicateGroups)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})

test_that("calculateFeatureCV", {
    
    expected_out <- regression_test_ner@featureCVPerMethod
    out <- calculateFeatureCV(normMatrices)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})

test_that("calculateAvgMadMem", {
    
    expected_out <- regression_test_ner@avgmadmem
    out <- calculateAvgMadMem(normMatrices, sampleReplicateGroups)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})

test_that("calculateAvgReplicateVariation", {
    
    expected_out <- regression_test_ner@avgvarmem
    out <- calculateAvgReplicateVariation(normMatrices, sampleReplicateGroups)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})


test_that("calculateANOVAPValues", {
    
    expected_out <- regression_test_ner@anovaP
    sampleReplicateGroups <- regression_test_nr@nds@sampleReplicateGroups
    
    expect_that(
        all.equal(
            expected_out,
            anova_pvalues
        ),
        is_true()
    )
}) 

test_that("findLowlyVariableFeatures", {
    
    expected_out <- regression_test_ner@nonsiganfdrlist
    log2AnovaFDR <- stats::p.adjust(
        anova_pvalues[, 1][!is.na(anova_pvalues[, 1])], method="BH")
    out <- findLowlyVariableFeatures(log2AnovaFDR, normMatrices)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})

test_that("calculatePercentageAvgDiffInMat_small_test", {
    
    test_mat <- data.frame(c(1,3), c(1,5), c(1,7))
    expect_out <- c(100, 150, 200)
    out <- calculatePercentageAvgDiffInMat(test_mat)
    
    expect_that(
        all.equal(
            out,
            expect_out
        ),
        is_true()
    )
})

test_that("calculatePercentageAvgDiffInMat_MAD", {
    
    expected_out <- regression_test_ner@avgmadmempdiff
    avgMadMemMat <- calculateAvgMadMem(normMatrices, sampleReplicateGroups)
    out <- calculatePercentageAvgDiffInMat(avgMadMemMat)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})

test_that("calculatePercentageAvgDiffInMat_CV", {
    
    expected_out <- regression_test_ner@avgcvmempdiff
    avgCVMat <- calculateReplicateCV(normMatrices, sampleReplicateGroups)
    out <- calculatePercentageAvgDiffInMat(avgCVMat)
    
    expect_that(
        all.equal(
            expected_out,
            out
        ),
        is_true()
    )
})


