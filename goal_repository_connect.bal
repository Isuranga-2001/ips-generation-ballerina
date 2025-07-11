import ballerina/http;
import ballerinax/health.fhir.r4;
import ballerinax/health.fhir.r4.parser;
import ballerinax/health.fhir.r4.uscore700;

isolated uscore700:USCoreGoalProfile[] goals = [];
isolated int createOperationNextIdGoal = 12344;

public isolated function createGoal(json payload) returns r4:FHIRError|uscore700:USCoreGoalProfile {
    uscore700:USCoreGoalProfile|error goal = parser:parse(payload, uscore700:USCoreGoalProfile).ensureType();

    if goal is error {
        return r4:createFHIRError(goal.message(), r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_BAD_REQUEST);
    } else {
        lock {
            createOperationNextIdGoal += 1;
            goal.id = (createOperationNextIdGoal).toBalString();
        }

        lock {
            goals.push(goal.clone());
        }

        return goal;
    }
}

public isolated function getByIdGoal(string id) returns r4:FHIRError|uscore700:USCoreGoalProfile {
    lock {
        foreach var item in goals {
            string result = item.id ?: "";

            if result == id {
                return item.clone();
            }
        }
    }
    return r4:createFHIRError(string `Cannot find a goal resource with id: ${id}`, r4:ERROR, r4:INVALID, httpStatusCode = http:STATUS_NOT_FOUND);
}

public isolated function searchGoal(map<string[]>? searchParameters = ()) returns r4:FHIRError|r4:Bundle {
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
                "subject" => {
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

        uscore700:USCoreGoalProfile[] results;
        lock {
            results = goals.clone();
        }

        if id is string {
            uscore700:USCoreGoalProfile byId = check getByIdGoal(id);
            results = [byId];
        }

        if patient is string {
            results = getByPatientGoal(patient, results);
        }

        r4:BundleEntry[] bundleEntries = [];
        foreach uscore700:USCoreGoalProfile item in results {
            r4:BundleEntry bundleEntry = {
                'resource: item
            };
            bundleEntries.push(bundleEntry);
        }

        bundle.entry = bundleEntries;
        bundle.total = results.length();
    } else {
        uscore700:USCoreGoalProfile[] allGoals;
        lock {
            allGoals = goals.clone();
        }
        
        r4:BundleEntry[] bundleEntries = [];
        foreach var item in allGoals {
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

isolated function getByPatientGoal(string patient, uscore700:USCoreGoalProfile[] goals) returns uscore700:USCoreGoalProfile[] {
    uscore700:USCoreGoalProfile[] filteredGoals = [];
    foreach uscore700:USCoreGoalProfile goal in goals {
        if goal.subject.reference == string `Patient/${patient}` {
            filteredGoals.push(goal);
        }
    }
    return filteredGoals;
}

function initGoal() returns error? {
    lock {
        json goalJson = {
            "resourceType": "Goal",
            "id": "12344",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-goal|7.0.0"]
            },
            "text": {
                "status": "generated",
                "div": "<div xmlns=\"http://www.w3.org/1999/xhtml\"><p><b>Generated Narrative: Goal</b><a name=\"goal-1\"> </a><a name=\"hcgoal-1\"> </a></p><div style=\"display: inline-block; background-color: #d9e0e7; padding: 6px; margin: 4px; border: 1px solid #8da1b4; border-radius: 5px; line-height: 60%\"><p style=\"margin-bottom: 0px\">Resource Goal &quot;goal-1&quot; </p><p style=\"margin-bottom: 0px\">Profile: <a href=\"StructureDefinition-us-core-goal.html\">US Core Goal Profile (version 7.0.0)</a></p></div><p><b>lifecycleStatus</b>: active</p><p><b>description</b>: Patient is targeting a pulse oximetry of 92% and a weight of 195 lbs <span style=\"background: LightGoldenRodYellow; margin: 4px; border: 1px solid khaki\"> ()</span></p><p><b>subject</b>: <a href=\"Patient-example.html\">Patient/example: Amy Shaw</a> &quot; SHAW&quot;</p><h3>Targets</h3><table class=\"grid\"><tr><td style=\"display: none\">-</td><td><b>Due[x]</b></td></tr><tr><td style=\"display: none\">*</td><td>2016-04-05</td></tr></table></div>"
            },
            "lifecycleStatus": "active",
            "description": {
                "text": "Patient is targeting a pulse oximetry of 92% and a weight of 195 lbs"
            },
            "subject": {
                "reference": "Patient/example",
                "display": "Amy Shaw"
            },
            "target": [
                {
                    "dueDate": "2016-04-05"
                }
            ]
        };
        uscore700:USCoreGoalProfile goal = check parser:parse(goalJson, uscore700:USCoreGoalProfile).ensureType();
        goals.push(goal.clone());

        // Add a second goal with a different patient for testing patient filtering
        json goalJson2 = {
            "resourceType": "Goal",
            "id": "12345",
            "meta": {
                "profile": ["http://hl7.org/fhir/us/core/StructureDefinition/us-core-goal|7.0.0"]
            },
            "lifecycleStatus": "active",
            "description": {
                "text": "Patient is targeting a blood pressure of 120/80 mmHg"
            },
            "subject": {
                "reference": "Patient/102",
                "display": "John Doe"
            },
            "target": [
                {
                    "measure": {
                        "coding": [
                            {
                                "system": "http://loinc.org",
                                "code": "85354-9",
                                "display": "Blood pressure panel"
                            }
                        ]
                    },
                    "detailQuantity": {
                        "value": 120,
                        "unit": "mmHg",
                        "system": "http://unitsofmeasure.org",
                        "code": "mm[Hg]"
                    },
                    "dueDate": "2025-12-31"
                }
            ]
        };

        uscore700:USCoreGoalProfile goal2 = check parser:parse(goalJson2, uscore700:USCoreGoalProfile).ensureType();
        goals.push(goal2.clone());
    }
}
