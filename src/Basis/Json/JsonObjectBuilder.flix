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

    pub enum JsonObjectBuilder[r: Region, ka: Type, a: Type](MonadLib.MutStateError[r, ka, Interop/Json.JsonObjectBuilder[r], a])

    instance Functor[JsonObjectBuilder[r, ka]] {
        pub def map(f: a -> b \ ef, ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef = 
            Basis/Json/JsonObjectBuilder.map(f, ma)
    }

    instance Applicative[JsonObjectBuilder[r, ka]] {
        pub def point(x: a): JsonObjectBuilder[r, ka, a] = 
            Basis/Json/JsonObjectBuilder.point(x)
        
        pub def ap(mf: JsonObjectBuilder[r, ka, a -> b \ ef], ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef =
            Basis/Json/JsonObjectBuilder.ap(mf, ma)
    }

    instance Monad[JsonObjectBuilder[r, ka]] {
        pub def flatMap(f: a -> JsonObjectBuilder[r, ka, b] \ ef, ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef =
            Basis/Json/JsonObjectBuilder.flatMap(f, ma)
    }


}

namespace Basis/Json/JsonObjectBuilder {

    use Basis/Json.JsonObjectBuilder;
    use Basis/Json.JsonObjectBuilder.{JsonObjectBuilder};
    use Basis/Json.JsonArrayBuilder;
    use Basis/Json.JsonArrayBuilder.{JsonArrayBuilder};    
    use Interop/Json.JsonValue;

    pub def getJsonObjectBuilder(x: JsonObjectBuilder[r, ka, a]): MonadLib.MutStateError[r, ka, Interop/Json.JsonObjectBuilder[r], a] = 
        let JsonObjectBuilder(x1) = x;
        x1

    pub def point(x: a): JsonObjectBuilder[r, ka, a] = JsonObjectBuilder(MonadLib/MutStateError.point(x))
    
    pub def map(f: a -> b \ ef, ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef = 
        JsonObjectBuilder(MonadLib/MutStateError.map(f, getJsonObjectBuilder(ma)))

    pub def ap(mf: JsonObjectBuilder[r, ka, a -> b \ ef], ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef =
        JsonObjectBuilder(MonadLib/MutStateError.ap(getJsonObjectBuilder(mf), getJsonObjectBuilder(ma)))
        
    pub def flatMap(f: a -> JsonObjectBuilder[r, ka, b] \ ef, ma: JsonObjectBuilder[r, ka, a]): JsonObjectBuilder[r, ka, b] \ ef =
        JsonObjectBuilder(MonadLib/MutStateError.flatMap(f >> getJsonObjectBuilder, getJsonObjectBuilder(ma)))


    pub def throwError(msg: String): JsonObjectBuilder[r, ka, a] = 
        JsonObjectBuilder(MonadLib/MutStateError.throwError(msg))
    
    def liftSetter!(f: Interop/Json.JsonObjectBuilder[r] -> Interop/Json.JsonObjectBuilder[r] \ ef): JsonObjectBuilder[r, ka, Unit] \ ef =
        JsonObjectBuilder(MonadLib/MutStateError.liftSetter!(f)) |> Functor.ignore

    def liftSetterResult!(f: Interop/Json.JsonObjectBuilder[r] -> Result[Interop/Json.JsonObjectBuilder[r], err] \ ef): JsonObjectBuilder[r, ka, Unit] \ ef with ToString[err] =
        JsonObjectBuilder(MonadLib/MutStateError.liftSetterResult!(f)) |> Functor.ignore

    ///
    /// Returns the result of applying `ma` to the initial state `s`.
    ///
    pub def runBuilder(r: Region[r], 
                        ma: JsonObjectBuilder[r, a, a], 
                        s: Interop/Json.JsonObjectBuilder[r]): Result[a, String] \ r = 
        MonadLib/MutStateError.runMutStateError(r, getJsonObjectBuilder(ma), s)


    pub def build(r: Region[r], ma: JsonObjectBuilder[r, a, a]): Result[Interop/Json.JsonObject, String] \{ Read(r), Write(r) } = 
        buildRawBuilder(r, ma) |> Result.map(Interop/Json/JsonObjectBuilder.build)

    pub def buildRawBuilder(r: Region[r], ma: JsonObjectBuilder[r, a, a]): Result[Interop/Json.JsonObjectBuilder[r], String] \{ Read(r), Write(r) } = 
        let state1 = Interop/Json/Json.createObjectBuilder(r);
        match runBuilder(r, ma, state1) {
            case Err(msg) => Err(msg)
            case Ok(_)    => state1 |> Ok
        }

    pub def addNull!(name: String): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addNull!(name))

    pub def addBool!(name: String, value: Bool): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addBool!(name, value))

    pub def addBigInt!(name: String, value: BigInt): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addBigInt!(name, value))


    pub def addFloat64!(name: String, value: Float64): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addFloat64!(name, value))

    pub def addInt32!(name: String, value: Int32): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addInt32!(name, value))


    pub def addString!(name: String, value: String): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addString!(name, value))

    pub def addJsonValue!(name: String, value: JsonValue): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonObjectBuilder.addJsonValue!(name, value))


    pub def addJsonArrayBuilder!(r: Region[r], name: String, value: JsonArrayBuilder[r, ka, ka]): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        match Basis/Json/JsonArrayBuilder.buildRawBuilder(r, value) {
            case Ok(value1) => liftSetterResult!(Interop/Json/JsonObjectBuilder.addJsonArrayBuilder!(name, value = value1))
            case Err(msg)   => throwError(msg)
        }

    pub def addJsonObjectBuilder!(r: Region[r], name: String, value: JsonObjectBuilder[r, ka, ka]): JsonObjectBuilder[r, ka, Unit] \ Write(r) =
        match buildRawBuilder(r, value) {
            case Ok(value1) => liftSetterResult!(Interop/Json/JsonObjectBuilder.addJsonObjectBuilder!(name, value = value1))
            case Err(msg)   => throwError(msg)
        }
        
}
