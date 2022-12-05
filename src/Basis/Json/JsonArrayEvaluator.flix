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

    pub enum JsonArrayEvaluator[r: Region, ka: Type, a: Type](MonadLib.Evaluator[r, ka, Interop/Json.JsonArray, a])
        

    instance Functor[JsonArrayEvaluator[r, ka]] {
        pub def map(f: a -> b & ef, ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef = 
            Basis/Json/JsonArrayEvaluator.map(f, ma)
    }

    instance Applicative[JsonArrayEvaluator[r, ka]] {
        pub def point(x: a): JsonArrayEvaluator[r, ka, a] = 
            Basis/Json/JsonArrayEvaluator.point(x)

        pub def ap(mf: JsonArrayEvaluator[r, ka, a -> b & ef], ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef =
            Basis/Json/JsonArrayEvaluator.ap(mf, ma)
    }

    instance Monad[JsonArrayEvaluator[r, ka]] {
        pub def flatMap(f: a -> JsonArrayEvaluator[r, ka, b] & ef, ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef =
            Basis/Json/JsonArrayEvaluator.flatMap(f, ma)
    }
    
    instance MonadZero[JsonArrayEvaluator[r, ka]] {
        pub def empty(): JsonArrayEvaluator[r, ka, a] = 
            Basis/Json/JsonArrayEvaluator.empty()
    }
    
    instance MonadLib.MonadOr[JsonArrayEvaluator[r, ka]] {
        pub def orelse(a: JsonArrayEvaluator[r, ka, a], b: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, a] =
            Basis/Json/JsonArrayEvaluator.orelse(a, b)
    }

}

namespace Basis/Json/JsonArrayEvaluator {

    use Basis/Json.JsonArrayEvaluator;
    use Basis/Json.JsonArrayEvaluator.{JsonArrayEvaluator};
    use Basis/Json.JsonObjectEvaluator;
    use Basis/Json.JsonObjectEvaluator.{JsonObjectEvaluator};

    use Interop/Json.JsonArray;
    use Interop/Json.JsonArray.{JsonArray};
    use Interop/Json.JsonNumber;
    use Interop/Json.JsonNumber.{JsonNumber};
    use Interop/Json.JsonObject;
    use Interop/Json.JsonObject.{JsonObject};


    pub def getJsonArrayEvaluator(x: JsonArrayEvaluator[r, ka, a]): MonadLib.Evaluator[r, ka, Interop/Json.JsonArray, a] = 
        let JsonArrayEvaluator(x1) = x;
        x1
        
    pub def runJsonArrayEvaluator(r: Region[r], 
                                ma: JsonArrayEvaluator[r, a, a], 
                                arr: Interop/Json.JsonArray): Result[a, String] & r =
        MonadLib/Evaluator.runEvaluator(r, getJsonArrayEvaluator(ma), arr)


    pub def point(x: a): JsonArrayEvaluator[r, ka, a] = JsonArrayEvaluator(MonadLib/Evaluator.point(x))

            
    pub def map(f: a -> b & ef, ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef = 
        JsonArrayEvaluator(MonadLib/Evaluator.map(f, getJsonArrayEvaluator(ma)))

    pub def ap(mf: JsonArrayEvaluator[r, ka, a -> b & ef], ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef =
        JsonArrayEvaluator(MonadLib/Evaluator.ap(getJsonArrayEvaluator(mf), getJsonArrayEvaluator(ma)))

    pub def flatMap(f: a -> JsonArrayEvaluator[r, ka, b] & ef, ma: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, b] & ef =
        JsonArrayEvaluator(MonadLib/Evaluator.flatMap(f >> getJsonArrayEvaluator, getJsonArrayEvaluator(ma)))


    pub def throwError(msg: String): JsonArrayEvaluator[r, ka, a] = 
        JsonArrayEvaluator(MonadLib/Evaluator.throwError(msg))
    
    pub def empty(): JsonArrayEvaluator[r, ka, a] = JsonArrayEvaluator(MonadLib/Evaluator.empty())
        
    pub def orelse(ma: JsonArrayEvaluator[r, ka, a], mb: JsonArrayEvaluator[r, ka, a]): JsonArrayEvaluator[r, ka, a] =
        JsonArrayEvaluator(MonadLib/Evaluator.orelse(getJsonArrayEvaluator(ma), getJsonArrayEvaluator(mb)))

    def liftGetter(f: Interop/Json.JsonArray -> a & ef): JsonArrayEvaluator[r, ka, a] & ef =
        JsonArrayEvaluator(MonadLib/Evaluator.liftGetter(f))

    def liftGetterResult(f: Interop/Json.JsonArray -> Result[a, err] & ef): JsonArrayEvaluator[r, ka, a] & ef with ToString[err] =
        JsonArrayEvaluator(MonadLib/Evaluator.liftGetterResult(f))

    def liftActionResult(f: Unit -> Result[a, String] & ef): JsonArrayEvaluator[r, ka, a] & ef =          
        JsonArrayEvaluator(MonadLib/Evaluator.liftActionResult(f))

    pub def getBool(ix: Int32): JsonArrayEvaluator[r, ka, Bool] =
        liftGetterResult(Interop/Json/JsonArray.getBoolean(ix))

    pub def getBoolWithDefault(ix: Int32, defaultVal: Bool): JsonArrayEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonArray.getBooleanWithDefault(ix, defaultVal))

    pub def getInt32(ix: Int32): JsonArrayEvaluator[r, ka, Int32] =
        liftGetterResult(Interop/Json/JsonArray.getInt(ix))
    
    pub def getInt32WithDefault(ix: Int32, defaultVal: Int32): JsonArrayEvaluator[r, ka, Int32] =
        liftGetter(Interop/Json/JsonArray.getIntWithDefault(ix, defaultVal))

    pub def getJsonArray(ix: Int32): JsonArrayEvaluator[r, ka, JsonArray] =
        liftGetterResult(Interop/Json/JsonArray.getJsonArray(ix))

    pub def getJsonNumber(ix: Int32): JsonArrayEvaluator[r, ka, JsonNumber] =
        liftGetterResult(Interop/Json/JsonArray.getJsonNumber(ix))

    pub def getJsonObject(ix: Int32): JsonArrayEvaluator[r, ka, JsonObject] =
        liftGetterResult(Interop/Json/JsonArray.getJsonObject(ix))

    pub def getString(ix: Int32): JsonArrayEvaluator[r, ka, String] =
        liftGetterResult(Interop/Json/JsonArray.getString(ix))
    
    pub def getStringWithDefault(ix: Int32, defaultVal: String): JsonArrayEvaluator[r, ka, String] =
        liftGetter(Interop/Json/JsonArray.getStringWithDefault(ix, defaultVal))

    pub def isNull(ix: Int32): JsonArrayEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonArray.isNull(ix))


    pub def evalJsonObject(r: Region[r], ix: Int32, ma: JsonObjectEvaluator[r, a, a]): JsonArrayEvaluator[r, ka, a] & r =
        let* obj = getJsonObject(ix);
        liftActionResult(_ -> Basis/Json/JsonObjectEvaluator.runJsonObjectEvaluator(r, ma, obj))
        
    pub def evalJsonArray(r: Region[r], ix: Int32, ma: JsonArrayEvaluator[r, a, a]): JsonArrayEvaluator[r, ka, a] & r =
        let* obj = getJsonArray(ix);
        liftActionResult(_ -> runJsonArrayEvaluator(r, ma, obj))

    pub def size(): JsonArrayEvaluator[r, ka, Int32] =
        liftGetter(Interop/Json/JsonArray.size)

    pub def isEmpty(): JsonArrayEvaluator[r, ka, Bool] =
        liftGetter(Interop/Json/JsonArray.isEmpty)


}

