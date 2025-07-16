    __device__ void bsdfReflect2(const DeviceMaterial& material, const TriHit& triHit, unsigned int& localSeed, Vec3& runningAlbedo) {
        /*
            i = tangent
            j = bitangent
            k = normal

            local space = tangent space
            l_ = basis vectors are in local/tangent space
            g_ = basis vectors are in global space
        */
        float u1 = randUniform(localSeed);
        float u2 = randUniform(localSeed);
        bool refract = u1 < material.transmission;
        bool diffuse = u2 < powf(material.roughness, 1.0f/5.0f);

        // for naming convention
        Vec3& g_direction = direction;
        Vec3& g_origin = origin;

        // get uv coords of intersection
        Vec3 triUV = triHit.tri->getUV(triHit.baryCoords);

        // prod the albedo
        Vec3 triAlbedo = material.getAlbedo(triUV.x,triUV.y);
        runningAlbedo *= triAlbedo;

        // get tri normal
        Vec3 g_edge1 = triHit.tri->v1 - triHit.tri->v0;
        Vec3 g_edge2 = triHit.tri->v2 - triHit.tri->v0;
        Vec3 g_triNormal = (g_edge1).cross(g_edge2).normalized();

        // offset the normal
        Vec3 normalOffset = material.getNormalOffset(triUV.x,triUV.y);
        Vec3 g_normal = getNormalFromOffset(g_triNormal, g_edge1, normalOffset);

        bool facingFront = g_direction.dot(g_triNormal) < 0;
        if (!facingFront && !refract) {
            g_normal *= -1;
        }

        // create an orthonormal basis from our new normal
        Vec3 arbitrary = g_normal.x < .9 ? Vec3(1,0,0) : Vec3(0,1,0);
        Vec3 g_tangent = g_normal.cross(arbitrary).normalized();
        Vec3 g_bitangent = g_normal.cross(g_tangent).normalized();
        
        // make transform to take local vects into global space
        Transform3D localToGlobal = Transform3D(
            g_tangent,
            g_bitangent,
            g_normal
        );

        Transform3D globalToLocal = localToGlobal.inverse();

        // get the ray in local space
        Vec3 l_rayDirection = (g_direction * globalToLocal).normalized();

        if (refract) {
            // we need to refract
            /*
            source:
             - https://shaderbits.com/blog/optimized-snell-s-law-refraction
             - https://www.cse.chalmers.se/edu/year/2013/course/TDA361/refractionvector.pdf
            */
            float ni, nr;
            Vec3 refractionNormal;
            if (facingFront) {
                // we are hittign the front of the tri (going in, normal faces toward us)
                ni = 1.0f;
                nr = material.IOR;

                refractionNormal = g_normal;
            } else {
                // we are hitting the back of the tri (going out, normal faces away)
                ni = material.IOR;
                nr = 1.0f;

                refractionNormal = -g_normal;
            }

            // remembering that a.b = |a||b|*cos(theta)
            float cosThetaI = -refractionNormal.dot(g_direction); // |normal| = 1 and |incident| = 1

            float n = ni/nr;
            float discriminant = 1 - n * n * (1 - cosThetaI * cosThetaI);

            if (discriminant < 1e-4f) {
                // TIR
                g_direction = (g_direction - 2 * refractionNormal.dot(g_direction) * refractionNormal).normalized();

                // set the origin of our new ray
                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
                
            } else {
                // refraction
                g_direction = (n * g_direction + ((n * cosThetaI) - sqrtf(discriminant)) * refractionNormal).normalized();

                // set the origin of our new ray
                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            }
        } else {
            // we need to reflect
            if (diffuse) {
                // diffuse reflect
                // cosine weighted sampling
                // get some fresh rand numbs
                u1 = randUniform(localSeed);
                u2 = randUniform(localSeed);

                float r = sqrtf(u1);
                float phi = 2.0f * 3.1415926 * u2;

                Vec3 localRay = Vec3(
                    r * cosf(phi),
                    r * sinf(phi),
                    sqrt(1.0f - u1)
                );

                g_direction = (localRay * localToGlobal).normalized();

                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            } else {
                // mirror reflect
                // R = I - 2(ProjN(I))
                g_direction = (g_direction - 2*(g_direction.dot(g_normal))*g_normal).normalized();

                g_origin = (triHit.intersecPoint).epsilonShift(g_direction);
            }
        }
    }
