import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.uscore700;

isolated uscore700:USCoreConditionEncounterDiagnosisProfile[] conditions = [];
isolated int createOperationNextIdCondition = 12344;

public isolated function createCondition(json payload) returns r4:FHIRError|uscore700:USCoreConditionEncounterDiagnosisProfile {
    uscore700:USCoreConditionEncounterDiagnosisProfile|error condition = parser:parse(payload, uscore700:USCoreConditionEncounterDiagnosisProfile).ensureType();

    if condition is error {
        return r4:createFHIRError(condition.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            createOperationNextIdCondition += 1;
            condition.id = (createOperationNextIdCondition).toBalString();
        }

        lock {
            conditions.push(condition.clone());
        }

        return condition;
    }
}

public isolated function getByIdCondition(string id) returns r4:FHIRError|uscore700:USCoreConditionEncounterDiagnosisProfile {
    lock {
        foreach var item in conditions {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a condition resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function searchCondition(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
    r4:Bundle bundle = {
        'type: "collection"
    };

    if searchParameters is map<string[]> {
        string? id = ();
        string? patient = ();

        foreach var 'key in searchParameters.keys() {
            match 'key {
                "_id" => {
                    id = searchParameters.get('key)[0];
                }
                "patient" => {
                    patient = searchParameters.get('key)[0];
                }
                "_count" => {
                    // pagination is not used in this service
                    continue;
                }
                _ => {
                    return r4:createFHIRError(string `Not supported search parameter: ${'key}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_IMPLEMENTED);
                }
            }
        }

        uscore700:USCoreConditionEncounterDiagnosisProfile[] results;
        lock {
            results = conditions.clone();
        }

        if id is string {
            uscore700:USCoreConditionEncounterDiagnosisProfile byId = check getByIdCondition(id);
            results = [byId];
        }

        if patient is string {
            results = getByPatientCondition(patient, results);
        }

        r4:BundleEntry[] bundleEntries = [];
        foreach uscore700:USCoreConditionEncounterDiagnosisProfile item in results {
            r4:BundleEntry bundleEntry = {
                'resource: item
            };
            bundleEntries.push(bundleEntry);
        }

        bundle.entry = bundleEntries;
        bundle.total = results.length();
    } else {
        uscore700:USCoreConditionEncounterDiagnosisProfile[] allConditions;
        lock {
            allConditions = conditions.clone();
        }
        
        r4:BundleEntry[] bundleEntries = [];
        foreach var item in allConditions {
            r4:BundleEntry bundleEntry = {
                'resource: item
            };
            bundleEntries.push(bundleEntry);
        }
        bundle.entry = bundleEntries;
        bundle.total = bundleEntries.length();
    }

    return bundle;
}

isolated function getByPatientCondition(string patient, uscore700:USCoreConditionEncounterDiagnosisProfile[] conditions) returns uscore700:USCoreConditionEncounterDiagnosisProfile[] {
    uscore700:USCoreConditionEncounterDiagnosisProfile[] filteredConditions = [];
    foreach uscore700:USCoreConditionEncounterDiagnosisProfile condition in conditions {
        if condition.subject.reference == string `Patient/${patient}` {
            filteredConditions.push(condition);
        }
    }
    return filteredConditions;
}

function initCondition() returns error? {
    lock {
        json conditionJson = {
            "resourceType": "Condition",
            "id": "12344",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition-encounter-diagnosis"]
            },
            "text": {
                "status": "extensions",
                "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Generated Narrative: Condition</b><a name=\"encounter-diagnosis-example1\"> </a><a name=\"hcencounter-diagnosis-example1\"> </a></p><div style=\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\"><p style=\"margin-bottom: 0px\">Resource Condition &quot;encounter-diagnosis-example1&quot; </p><p style=\"margin-bottom: 0px\">Profile: <a href=\"StructureDefinition-us-core-condition-encounter-diagnosis.html\">US Core Condition Encounter Diagnosis Profile (version 7.0.0)</a></p></div><p><b>Condition Asserted Date</b>: 2015-10-31</p><p><b>clinicalStatus</b>: Resolved <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.5.0/CodeSystem-condition-clinical.html\">Condition Clinical Status Codes</a>#resolved)</span></p><p><b>verificationStatus</b>: Confirmed <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.5.0/CodeSystem-condition-ver-status.html\">ConditionVerificationStatus</a>#confirmed)</span></p><p><b>category</b>: Encounter Diagnosis <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"http://terminology.hl7.org/5.5.0/CodeSystem-condition-category.html\">Condition Category Codes</a>#encounter-diagnosis)</span></p><p><b>code</b>: Burnt Ear <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> (<a href=\"https://browser.ihtsdotools.org/\">SNOMED CT[US]</a>#39065001 &quot;Burn of ear&quot;)</span></p><p><b>subject</b>: <a href=\"Patient-example.html\">Patient/example: Amy Shaw</a> &quot; SHAW&quot;</p><p><b>encounter</b>: <a href=\"Encounter-example-1.html\">Encounter/example-1</a></p><p><b>onset</b>: 2015-10-31</p><p><b>abatement</b>: 2015-12-01</p><p><b>recordedDate</b>: 2015-11-01</p></div>"
            },
            "extension": [
                {
                    "url": "http://hl7.org/fhir/StructureDefinition/condition-assertedDate",
                    "valueDateTime": "2015-10-31"
                }
            ],
            "clinicalStatus": {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                        "code": "resolved"
                    }
                ]
            },
            "verificationStatus": {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
                        "code": "confirmed"
                    }
                ]
            },
            "category": [
                {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/condition-category",
                            "code": "encounter-diagnosis",
                            "display": "Encounter Diagnosis"
                        }
                    ]
                }
            ],
            "code": {
                "coding": [
                    {
                        "system": "http://snomed.info/sct",
                        "version": "http://snomed.info/sct/731000124108",
                        "code": "39065001",
                        "display": "Burn of ear"
                    }
                ],
                "text": "Burnt Ear"
            },
            "subject": {
                "reference": "Patient/example",
                "display": "Amy Shaw"
            },
            "encounter": {
                "reference": "Encounter/example-1"
            },
            "onsetDateTime": "2015-10-31",
            "abatementDateTime": "2015-12-01",
            "recordedDate": "2015-11-01"
        };

        uscore700:USCoreConditionEncounterDiagnosisProfile condition = check parser:parseWithValidation(conditionJson, uscore700:USCoreConditionEncounterDiagnosisProfile).ensureType();
        conditions.push(condition.clone());

        // Add a second condition with a different patient for testing patient filtering
        json conditionJson2 = {
            "resourceType": "Condition",
            "id": "12345",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-condition-encounter-diagnosis"]
            },
            "clinicalStatus": {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/condition-clinical",
                        "code": "active"
                    }
                ]
            },
            "verificationStatus": {
                "coding": [
                    {
                        "system": "http://terminology.hl7.org/CodeSystem/condition-ver-status",
                        "code": "confirmed"
                    }
                ]
            },
            "category": [
                {
                    "coding": [
                        {
                            "system": "http://terminology.hl7.org/CodeSystem/condition-category",
                            "code": "encounter-diagnosis",
                            "display": "Encounter Diagnosis"
                        }
                    ]
                }
            ],
            "code": {
                "coding": [
                    {
                        "system": "http://snomed.info/sct",
                        "code": "38341003",
                        "display": "Hypertension"
                    }
                ],
                "text": "Hypertension"
            },
            "subject": {
                "reference": "Patient/102",
                "display": "John Doe"
            },
            "encounter": {
                "reference": "Encounter/example-2"
            },
            "onsetDateTime": "2020-01-15",
            "recordedDate": "2020-01-20"
        };

        uscore700:USCoreConditionEncounterDiagnosisProfile condition2 = check parser:parseWithValidation(conditionJson2, uscore700:USCoreConditionEncounterDiagnosisProfile).ensureType();
        conditions.push(condition2.clone());
    }
}
