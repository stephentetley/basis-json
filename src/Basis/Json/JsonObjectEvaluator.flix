/*
 * Copyright 2022 Stephen Tetley
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

namespace Basis/Json {

    pub enum JsonObjectEvaluator[r: Region, ka: Type, a: Type](MonadLib.Evaluator[r, ka, Interop/Json.JsonObject, a])
        

    instance Functor[JsonObjectEvaluator[r, ka]] {
        pub def map(f: a -> b & ef, ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef = 
            Basis/Json/JsonObjectEvaluator.map(f, ma)
    }

    instance Applicative[JsonObjectEvaluator[r, ka]] {
        pub def point(x: a): JsonObjectEvaluator[r, ka, a] = 
            Basis/Json/JsonObjectEvaluator.point(x)

        pub def ap(mf: JsonObjectEvaluator[r, ka, a -> b & ef], ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef =
            Basis/Json/JsonObjectEvaluator.ap(mf, ma)
    }

    instance Monad[JsonObjectEvaluator[r, ka]] {
        pub def flatMap(f: a -> JsonObjectEvaluator[r, ka, b] & ef, ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef =
            Basis/Json/JsonObjectEvaluator.flatMap(f, ma)
    }

    instance MonadZero[JsonObjectEvaluator[r, ka]] {
        pub def empty(): JsonObjectEvaluator[r, ka, a] = 
            Basis/Json/JsonObjectEvaluator.empty()
    }
    
    instance MonadLib.MonadOr[JsonObjectEvaluator[r, ka]] {
        pub def orelse(a: JsonObjectEvaluator[r, ka, a], b: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, a] =
            Basis/Json/JsonObjectEvaluator.orelse(a, b)
    }


}

namespace Basis/Json/JsonObjectEvaluator {

    use Basis/Json.JsonObjectEvaluator;
    use Basis/Json.JsonObjectEvaluator.{JsonObjectEvaluator};
    use Basis/Json.JsonArrayEvaluator;
    use Basis/Json.JsonArrayEvaluator.{JsonArrayEvaluator};

    use Interop/Json.JsonArray;
    use Interop/Json.JsonArray.{JsonArray};
    use Interop/Json.JsonNumber;
    use Interop/Json.JsonNumber.{JsonNumber};
    use Interop/Json.JsonObject;
    use Interop/Json.JsonObject.{JsonObject};


    pub def getJsonObjectEvaluator(x: JsonObjectEvaluator[r, ka, a]): MonadLib.Evaluator[r, ka, Interop/Json.JsonObject, a] = 
        let JsonObjectEvaluator(x1) = x;
        x1

    pub def runJsonObjectEvaluator(r: Region[r], 
                                    ma: JsonObjectEvaluator[r, a, a], 
                                    obj: Interop/Json.JsonObject): Result[a, String] & r =
        MonadLib/Evaluator.runEvaluator(r, getJsonObjectEvaluator(ma), obj)

    pub def point(x: a): JsonObjectEvaluator[r, ka, a] = JsonObjectEvaluator(MonadLib/Evaluator.point(x))

            
    pub def map(f: a -> b & ef, ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef = 
        JsonObjectEvaluator(MonadLib/Evaluator.map(f, getJsonObjectEvaluator(ma)))

    pub def ap(mf: JsonObjectEvaluator[r, ka, a -> b & ef], ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef =
        JsonObjectEvaluator(MonadLib/Evaluator.ap(getJsonObjectEvaluator(mf), getJsonObjectEvaluator(ma)))

    pub def flatMap(f: a -> JsonObjectEvaluator[r, ka, b] & ef, ma: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, b] & ef =
        JsonObjectEvaluator(MonadLib/Evaluator.flatMap(f >> getJsonObjectEvaluator, getJsonObjectEvaluator(ma)))


    pub def throwError(msg: String): JsonObjectEvaluator[r, ka, a] = 
        JsonObjectEvaluator(MonadLib/Evaluator.throwError(msg))
    
    pub def empty(): JsonObjectEvaluator[r, ka, a] = JsonObjectEvaluator(MonadLib/Evaluator.empty())
        

    pub def orelse(ma: JsonObjectEvaluator[r, ka, a], mb: JsonObjectEvaluator[r, ka, a]): JsonObjectEvaluator[r, ka, a] =
        JsonObjectEvaluator(MonadLib/Evaluator.orelse(getJsonObjectEvaluator(ma), getJsonObjectEvaluator(mb)))


    def liftGetter(f: Interop/Json.JsonObject -> a & ef): JsonObjectEvaluator[r, ka, a] & ef =
        JsonObjectEvaluator(MonadLib/Evaluator.liftGetter(f))

    def liftGetterResult(f: Interop/Json.JsonObject -> Result[a, err] & ef): JsonObjectEvaluator[r, ka, a] & ef with ToString[err] =
        JsonObjectEvaluator(MonadLib/Evaluator.liftGetterResult(f))


    def liftActionResult(f: Unit -> Result[a, String] & ef): JsonObjectEvaluator[r, ka, a] & ef =          
        JsonObjectEvaluator(MonadLib/Evaluator.liftActionResult(f))

    pub def getBool(name: String): JsonObjectEvaluator[r, ka, Bool] =
        liftGetterResult(Interop/Json/JsonObject.getBoolean(name))

    pub def getBoolWithDefault(name: String, defaultVal: Bool): JsonObjectEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonObject.getBooleanWithDefault(name, defaultVal))

    pub def getInt32(name: String): JsonObjectEvaluator[r, ka, Int32] =
        liftGetterResult(Interop/Json/JsonObject.getInt(name))
    
    pub def getInt32WithDefault(name: String, defaultVal: Int32): JsonObjectEvaluator[r, ka, Int32] =
        liftGetter(Interop/Json/JsonObject.getIntWithDefault(name, defaultVal))

    pub def getJsonArray(name: String): JsonObjectEvaluator[r, ka, JsonArray] =
        liftGetterResult(Interop/Json/JsonObject.getJsonArray(name))

    pub def getJsonNumber(name: String): JsonObjectEvaluator[r, ka, JsonNumber] =
        liftGetterResult(Interop/Json/JsonObject.getJsonNumber(name))

    pub def getJsonObject(name: String): JsonObjectEvaluator[r, ka, JsonObject] =
        liftGetterResult(Interop/Json/JsonObject.getJsonObject(name))

    pub def getString(name: String): JsonObjectEvaluator[r, ka, String] =
        liftGetterResult(Interop/Json/JsonObject.getString(name))
    
    pub def getStringWithDefault(name: String, defaultVal: String): JsonObjectEvaluator[r, ka, String] =
        liftGetter(Interop/Json/JsonObject.getStringWithDefault(name, defaultVal))

    pub def isNull(name: String): JsonObjectEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonObject.isNull(name))

    pub def evalJsonObject(name: String, ma: JsonObjectEvaluator[r, a, a]): JsonObjectEvaluator[r, ka, a] & r =
        let* obj = getJsonObject(name);
        liftActionResult(_ -> runJsonObjectEvaluator(() as Region[r], ma, obj))
        
    pub def evalJsonArray(name: String, ma: JsonArrayEvaluator[r, a, a]): JsonObjectEvaluator[r, ka, a] & r =
        let* obj = getJsonArray(name);
        liftActionResult(_ -> Basis/Json/JsonArrayEvaluator.runJsonArrayEvaluator(() as Region[r], ma, obj))


    pub def size(): JsonObjectEvaluator[r, ka, Int32] =
        liftGetter(Interop/Json/JsonObject.size)

    pub def isEmpty(): JsonObjectEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonObject.isEmpty)

}

