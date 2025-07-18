import ballerina/log;

function init() returns error? {
    check initPatient();
    check initOrg();
    check initAllergy();
    check initCondition();
    check initGoal();
    check initMedicationStatement();
    check initMedication();
    check initImmunization();

    log:printInfo("FHIR service initialized successfully");
}