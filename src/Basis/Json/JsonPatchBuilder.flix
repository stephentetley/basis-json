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

    pub enum JsonPatchBuilder[r: Region, ka: Type, a: Type](MonadLib.Builder[r, ka, Interop/Json.JsonPatchBuilder[r], a])

    instance Functor[JsonPatchBuilder[r, ka]] {
        pub def map(f: a -> b \ ef, ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef = 
            Basis/Json/JsonPatchBuilder.map(f, ma)
    }

    instance Applicative[JsonPatchBuilder[r, ka]] {
        pub def point(x: a): JsonPatchBuilder[r, ka, a] = 
            Basis/Json/JsonPatchBuilder.point(x)
        
        pub def ap(mf: JsonPatchBuilder[r, ka, a -> b \ ef], ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef =
            Basis/Json/JsonPatchBuilder.ap(mf, ma)
    }

    instance Monad[JsonPatchBuilder[r, ka]] {
        pub def flatMap(f: a -> JsonPatchBuilder[r, ka, b] \ ef, ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef =
            Basis/Json/JsonPatchBuilder.flatMap(f, ma)
    }


}

namespace Basis/Json/JsonPatchBuilder {

    use Basis/Json.JsonPatchBuilder;
    use Basis/Json.JsonPatchBuilder.{JsonPatchBuilder};

    // use Interop/Json.JsonArrayBuilder;
    // use Interop/Json.JsonArrayBuilder.{JsonArrayBuilder};    
    // use Interop/Json.JsonObject;
    // use Interop/Json.JsonObject.{JsonObject};
    // use Interop/Json.JsonValue;
    // use Interop/Json.JsonValue.{JsonValue};

    pub def getJsonPatchBuilder(x: JsonPatchBuilder[r, ka, a]): MonadLib.Builder[r, ka, Interop/Json.JsonPatchBuilder[r], a] = 
        let JsonPatchBuilder(x1) = x;
        x1

    pub def point(x: a): JsonPatchBuilder[r, ka, a] = JsonPatchBuilder(MonadLib/Builder.point(x))
    
    pub def map(f: a -> b \ ef, ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef = 
        JsonPatchBuilder(MonadLib/Builder.map(f, getJsonPatchBuilder(ma)))

    pub def ap(mf: JsonPatchBuilder[r, ka, a -> b \ ef], ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef =
        JsonPatchBuilder(MonadLib/Builder.ap(getJsonPatchBuilder(mf), getJsonPatchBuilder(ma)))
        
    pub def flatMap(f: a -> JsonPatchBuilder[r, ka, b] \ ef, ma: JsonPatchBuilder[r, ka, a]): JsonPatchBuilder[r, ka, b] \ ef =
        JsonPatchBuilder(MonadLib/Builder.flatMap(f >> getJsonPatchBuilder, getJsonPatchBuilder(ma)))


    pub def throwError(msg: String): JsonPatchBuilder[r, ka, a] = 
        JsonPatchBuilder(MonadLib/Builder.throwError(msg))
    
    pub def liftSetter(f: Interop/Json.JsonPatchBuilder[r] -> Interop/Json.JsonPatchBuilder[r] \ ef): JsonPatchBuilder[r, ka, Unit] \ ef =
        JsonPatchBuilder(MonadLib/Builder.liftSetter(f))

    ///
    /// Returns the result of applying `ma` to the initial state `s`.
    ///
    pub def runBuilder(r: Region[r], 
                        ma: JsonPatchBuilder[r, a, a], 
                        s: Interop/Json.JsonPatchBuilder[r]): Result[a, String] \ r = 
        MonadLib/Builder.runBuilder(r, getJsonPatchBuilder(ma), s)



    pub def build(r: Region[r], ma: JsonPatchBuilder[r, a, a]): Result[Interop/Json.JsonPatch, String] \{ Read(r), Write(r) } = 
        let state1 = Interop/Json/Json.createPatchBuilder(r);
        match runBuilder(r, ma, state1) {
            case Err(msg) => Err(msg)
            case Ok(_)    => Interop/Json/JsonPatchBuilder.build(state1) |> Ok
        }

    pub def addBool!(path: {path :: String}, value: Bool): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        liftSetter(Interop/Json/JsonPatchBuilder.addBool!(path, value))

    pub def addInt32!(path: {path :: String}, value: Int32): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        liftSetter(Interop/Json/JsonPatchBuilder.addInt32!(path, value))

    pub def addString!(path: {path :: String}, value: String): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        liftSetter(Interop/Json/JsonPatchBuilder.addString!(path, value))

/*



    pub def addBigInt(name: String, value: BigInt): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, BigInt): ##javax.json.JsonPatchBuilder & r;
        liftSetter(x1 -> add(x1, name, value))


    pub def addFloat64(name: String, value: Float64): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, Float64): ##javax.json.JsonPatchBuilder & r;
        liftSetter(x1 -> add(x1, name, value))

    pub def addInt32(name: String, value: Int32): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, Int32): ##javax.json.JsonPatchBuilder & r;
        liftSetter(x1 -> add(x1, name, value))


    pub def addString(name: String, value: String): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, String): ##javax.json.JsonPatchBuilder & r;
        liftSetter(x1 -> add(x1, name, value))

    pub def addJsonValue(name: String, value: JsonValue): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, ##javax.json.JsonValue): ##javax.json.JsonPatchBuilder & r;
        let JsonValue(v1) = value;
        liftSetter(x1 -> add(x1, name, v1))


    pub def addJsonArrayBuilder(name: String, value: JsonArrayBuilder[r, ka, ka]): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, ##javax.json.JsonArrayBuilder): ##javax.json.JsonPatchBuilder & r;
        import static javax.json.Json.createArrayBuilder(): ##javax.json.JsonArrayBuilder & r;
        let st = createArrayBuilder();
        match Interop/Json/JsonArrayBuilder.runBuilder(() as Region[r], value, st) {
            case Ok(_)    => liftSetter(x1 -> add(x1, name, st))
            case Err(msg) => throwError(msg)
        }

    pub def addJsonPatchBuilder(name: String, value: JsonPatchBuilder[r, ka, ka]): JsonPatchBuilder[r, ka, Unit] \ Write(r) =
        import javax.json.JsonPatchBuilder.add(String, ##javax.json.JsonPatchBuilder): ##javax.json.JsonPatchBuilder & r;
        import static javax.json.Json.createPatchBuilder(): ##javax.json.JsonPatchBuilder & r;
        let st = createPatchBuilder();
        match runBuilder(() as Region[r], value, st) {
            case Ok(_)    => liftSetter(x1 -> add(x1, name, st))
            case Err(msg) => throwError(msg)
        }
        
*/
        
}
