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

    pub enum JsonArrayBuilder[r: Region, ka: Type, a: Type](MonadLib.MutStateError[r, ka, Interop/Json.JsonArrayBuilder[r], a])

    instance Functor[JsonArrayBuilder[r, ka]] {
        pub def map(f: a -> b \ ef, ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef = 
            Basis/Json/JsonArrayBuilder.map(f, ma)
    }

    instance Applicative[JsonArrayBuilder[r, ka]] {
        pub def point(x: a): JsonArrayBuilder[r, ka, a] = 
            Basis/Json/JsonArrayBuilder.point(x)
        
        pub def ap(mf: JsonArrayBuilder[r, ka, a -> b \ ef], ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef =
            Basis/Json/JsonArrayBuilder.ap(mf, ma)
    }

    instance Monad[JsonArrayBuilder[r, ka]] {
        pub def flatMap(f: a -> JsonArrayBuilder[r, ka, b] \ ef, ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef =
            Basis/Json/JsonArrayBuilder.flatMap(f, ma)
    }


}

namespace Basis/Json/JsonArrayBuilder {

    use Basis/Json.JsonArrayBuilder;
    use Basis/Json.JsonArrayBuilder.{JsonArrayBuilder};
    use Basis/Json.JsonObjectBuilder;

    use Interop/Json.JsonValue;

    pub def getJsonArrayBuilder(x: JsonArrayBuilder[r, ka, a]): MonadLib.MutStateError[r, ka, Interop/Json.JsonArrayBuilder[r], a] = 
        let JsonArrayBuilder(x1) = x;
        x1

    pub def point(x: a): JsonArrayBuilder[r, ka, a] = JsonArrayBuilder(MonadLib/MutStateError.point(x))
    
    pub def map(f: a -> b \ ef, ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef = 
        JsonArrayBuilder(MonadLib/MutStateError.map(f, getJsonArrayBuilder(ma)))

    pub def ap(mf: JsonArrayBuilder[r, ka, a -> b \ ef], ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef =
        JsonArrayBuilder(MonadLib/MutStateError.ap(getJsonArrayBuilder(mf), getJsonArrayBuilder(ma)))
        
    pub def flatMap(f: a -> JsonArrayBuilder[r, ka, b] \ ef, ma: JsonArrayBuilder[r, ka, a]): JsonArrayBuilder[r, ka, b] \ ef =
        JsonArrayBuilder(MonadLib/MutStateError.flatMap(f >> getJsonArrayBuilder, getJsonArrayBuilder(ma)))


    pub def throwError(msg: String): JsonArrayBuilder[r, ka, a] = 
        JsonArrayBuilder(MonadLib/MutStateError.throwError(msg))
    
    def liftSetter!(f: Interop/Json.JsonArrayBuilder[r] -> Interop/Json.JsonArrayBuilder[r] \ ef): JsonArrayBuilder[r, ka, Unit] \ ef =
        JsonArrayBuilder(MonadLib/MutStateError.liftSetter!(f)) |> Functor.ignore
    
    def liftSetterResult!(f: Interop/Json.JsonArrayBuilder[r] -> Result[Interop/Json.JsonArrayBuilder[r], err] \ ef): JsonArrayBuilder[r, ka, Unit] \ ef with ToString[err] =
        JsonArrayBuilder(MonadLib/MutStateError.liftSetterResult!(f)) |> Functor.ignore


    ///
    /// Returns the result of applying `ma` to the initial state `s`.
    ///
    pub def runBuilder(r: Region[r], 
                        ma: JsonArrayBuilder[r, a, a], 
                        s: Interop/Json.JsonArrayBuilder[r]): Result[a, String] \ r = 
        MonadLib/MutStateError.runMutStateError(r, getJsonArrayBuilder(ma), s)


    pub def build(r: Region[r], ma: JsonArrayBuilder[r, a, a]): Result[Interop/Json.JsonArray, String] \{ Read(r), Write(r) } = 
        buildRawBuilder(r, ma) |> Result.map(Interop/Json/JsonArrayBuilder.build)

    pub def buildRawBuilder(r: Region[r], ma: JsonArrayBuilder[r, a, a]): Result[Interop/Json.JsonArrayBuilder[r], String] \{ Read(r), Write(r) } = 
        let state1 = Interop/Json/Json.createArrayBuilder(r);
        match runBuilder(r, ma, state1) {
            case Err(msg) => Err(msg)
            case Ok(_)    => state1 |> Ok
        }


    pub def addNull!(): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addNull!)


    pub def addBool!(value: Bool): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addBool!(value))
        

    pub def addBigInt!(value: BigInt): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addBigInt!(value))


    pub def addFloat64!(value: Float64): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addFloat64!(value))

    pub def addInt32!(value: Int32): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addInt32!(value))

    pub def addString!(value: String): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addString!(value))

    pub def addJsonValue!(value: JsonValue): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        liftSetter!(Interop/Json/JsonArrayBuilder.addJsonValue!(value))


    pub def addJsonArrayBuilder!(r: Region[r], value: JsonArrayBuilder[r, ka, ka]): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        match buildRawBuilder(r, value) {
            case Ok(value1) => liftSetterResult!(Interop/Json/JsonArrayBuilder.addJsonArrayBuilder!(value = value1))
            case Err(msg)   => throwError(msg)
        }

    pub def addJsonObjectBuilder!(r: Region[r], value: JsonObjectBuilder[r, ka, ka]): JsonArrayBuilder[r, ka, Unit] \ Write(r) =
        match Basis/Json/JsonObjectBuilder.buildRawBuilder(r, value) {
            case Ok(value1) => liftSetterResult!(Interop/Json/JsonArrayBuilder.addJsonObjectBuilder!(value = value1))
            case Err(msg)   => throwError(msg)
        }
        

        
}
